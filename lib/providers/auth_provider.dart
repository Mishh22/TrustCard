import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_card.dart';
import '../services/firebase_service.dart';
import '../services/data_migration_service.dart';
import '../services/profile_service.dart';
import '../utils/logger.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  UserCard? _currentUser;
  bool _isLoading = false;
  String? _error;
  ConfirmationResult? _confirmationResult;
  String? _verificationId;
  StreamSubscription? _userCardSubscription;

  UserCard? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Debug method to check OTP session state
  void debugOTPSession() {
    Logger.debug('=== OTP Session Debug ===');
    Logger.debug('Verification ID: ${_verificationId ?? "null"}');
    Logger.debug('Confirmation Result: ${_confirmationResult != null ? "exists" : "null"}');
    Logger.debug('Is Loading: $_isLoading');
    Logger.debug('Current Error: ${_error ?? "none"}');
    Logger.debug('Current User: ${_currentUser != null ? "authenticated" : "not authenticated"}');
    Logger.debug('========================');
  }
  
  // Clear OTP session and start fresh
  void clearOTPSession() {
    Logger.debug('Clearing OTP session...');
    _verificationId = null;
    _confirmationResult = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }
  
  // Initialize user from Firebase on app start
  Future<void> initializeUser() async {
    final firebaseUser = FirebaseService.getCurrentUser();
    if (firebaseUser != null) {
      await _loadUserFromFirestore(firebaseUser.uid);
      _setupRealtimeSync(firebaseUser.uid);
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final userData = await FirebaseService.getUserCard(userId);
      if (userData != null) {
        _currentUser = UserCard.fromMap(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from Firestore: $e');
    }
  }

  // Set up real-time sync listener for user data changes
  void _setupRealtimeSync(String userId) {
    _userCardSubscription?.cancel();
    _userCardSubscription = FirebaseService.getUserCardStream(userId).listen(
      (userData) {
        if (userData != null) {
          _currentUser = UserCard.fromMap(userData);
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error in real-time sync: $error');
      },
    );
  }

  // Save user data to Firestore (automatically syncs to all devices)
  Future<void> _saveUserToFirestore(UserCard user) async {
    try {
      // Debug logging
      print('💾 DEBUG: Attempting to save user to Firestore');
      print('💾 DEBUG: user.id = ${user.id}');
      print('💾 DEBUG: user.userId = ${user.userId}');
      
      // Validate userId before saving
      if (user.userId.isEmpty) {
        throw Exception('User ID is empty - cannot save to Firestore');
      }
      
      // Use user.userId (the actual user ID) instead of user.id (card ID)
      print('💾 DEBUG: Calling FirebaseService.saveUserCard with userId: ${user.userId}');
      
      // Add timeout and better error handling
      await FirebaseService.saveUserCard(user.userId, user.toMap()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏰ Firestore save operation timed out after 15 seconds');
          throw Exception('Firestore save operation timed out after 15 seconds');
        },
      );
      
      print('✅ DEBUG: User saved successfully to Firestore');
    } catch (e) {
      print('❌ ERROR saving user to Firestore: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');
      
      // Don't rethrow - let the authentication continue even if Firestore save fails
      print('⚠️ Continuing authentication despite Firestore save error');
    }
  }
  
  /// Trigger migration if user data needs to be migrated to new structure
  Future<void> _triggerMigrationIfNeeded(String userId) async {
    try {
      Logger.info('Checking migration status for user: $userId');
      
      // Check if user profile exists in new structure
      final profileExists = await ProfileService.profileExists(userId);
      
      if (!profileExists) {
        Logger.info('User not migrated, starting migration: $userId');
        await DataMigrationService.migrateUserData(userId);
        Logger.success('Migration completed for user: $userId');
      } else {
        Logger.info('User already migrated: $userId');
      }
    } catch (e) {
      Logger.error('Error during migration check: $e');
      // Don't fail login if migration fails
    }
  }

  /// Update FCM token for push notifications
  Future<void> _updateFCMToken(String userId) async {
    try {
      final fcmToken = await FirebaseService.getFCMToken();
      if (fcmToken != null) {
        await ProfileService.updateFCMToken(userId, fcmToken);
        Logger.info('FCM token updated for user: $userId');
      } else {
        Logger.warning('No FCM token available for user: $userId');
      }
    } catch (e) {
      Logger.error('Error updating FCM token: $e');
      // Don't fail login if FCM token update fails
    }
  }

  @override
  void dispose() {
    _userCardSubscription?.cancel();
    super.dispose();
  }
  
         // Removed admin system - app is user-driven

  // Simulate user login
  Future<bool> login(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data
      _currentUser = UserCard(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'John Doe',
        phoneNumber: phoneNumber,
        companyName: 'Company 1 Pvt Ltd',
        designation: 'Delivery Partner',
        companyId: 'SWG12345',
        verificationLevel: VerificationLevel.document,
        isCompanyVerified: false,
        customerRating: 4.5,
        totalRatings: 120,
        verifiedByColleagues: ['colleague1', 'colleague2'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        version: 1,
        isActive: true,
        uploadedDocuments: ['id_card.jpg', 'offer_letter.pdf'],
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Firebase logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Cancel real-time subscription
      _userCardSubscription?.cancel();
      _userCardSubscription = null;
      
      await FirebaseService.signOut();
      _currentUser = null;
      _confirmationResult = null;
      _verificationId = null;
      
      _setLoading(false);
      notifyListeners(); // Notify UI immediately
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      _setLoading(false);
      notifyListeners(); // Notify UI even on error
    }
  }

  // Update user profile (automatically syncs to all devices)
  Future<bool> updateProfile({
    String? fullName,
    String? companyName,
    String? designation,
    String? profilePhotoUrl,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      // Update local user data
      _currentUser = _currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        companyName: companyName ?? _currentUser!.companyName,
        designation: designation ?? _currentUser!.designation,
        profilePhotoUrl: profilePhotoUrl ?? _currentUser!.profilePhotoUrl,
      );
      
      // Save to old collection (for backward compatibility)
      await _saveUserToFirestore(_currentUser!);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Send OTP using Firebase Phone Authentication
  Future<bool> sendOTP(String phoneNumber) async {
    print('📱 ========== SEND OTP START ==========');
    print('📱 Phone number received: $phoneNumber');
    
    _setLoading(true);
    _clearError();

    try {
      // Check if this is a test phone number for emulator
      if (_isTestPhoneNumber(phoneNumber)) {
        print('✅ Using test phone number - bypassing Firebase Auth');
        _verificationId = 'test_verification_id';
        _setLoading(false);
        notifyListeners();
        return true;
      }

      print('📱 Not a test number, proceeding with Firebase...');
      print('📱 Platform check: kIsWeb = $kIsWeb');

      if (kIsWeb) {
        print('🌐 Web platform - using signInWithPhoneNumber');
        // Web uses ConfirmationResult
        final confirmationResult = await FirebaseService.signInWithPhoneNumber(phoneNumber);
        if (confirmationResult != null) {
          print('✅ Web: Confirmation result received');
          _confirmationResult = confirmationResult;
          _setLoading(false);
          return true;
        } else {
          print('❌ Web: No confirmation result received');
        }
      } else {
        print('📱 Mobile platform - using verifyPhoneNumber');
        print('📱 Calling FirebaseService.verifyPhoneNumber...');
        
        // Mobile uses verifyPhoneNumber with callbacks
        final error = await FirebaseService.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification completed (test phone numbers or instant verification)
            print('✅ ========== AUTO-VERIFICATION COMPLETED ==========');
            print('✅ Auto-verification credential received');
            try {
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              if (userCredential.user != null) {
                final userId = userCredential.user!.uid;
                print('✅ Auto-sign in successful: $userId');
                final existingData = await FirebaseService.getUserCard(userId);
                
                if (existingData != null) {
                  print('✅ Existing user data found');
                  _currentUser = UserCard.fromMap(existingData);
                } else {
                  print('⚠️ New user - creating user data');
                  _currentUser = UserCard(
                    id: userId,
                    userId: userId,
                    fullName: userCredential.user!.displayName ?? 'User',
                    phoneNumber: phoneNumber,
                    companyName: '',
                    designation: '',
                    companyId: '',
                    verificationLevel: VerificationLevel.basic,
                    isCompanyVerified: false,
                    customerRating: 0.0,
                    totalRatings: 0,
                    verifiedByColleagues: [],
                    createdAt: DateTime.now(),
                    version: 1,
                    isActive: true,
                  );
                  await FirebaseService.saveUserCard(userId, _currentUser!.toMap());
                  print('✅ New user saved to Firestore');
                }
                _setupRealtimeSync(userId);
                print('✅ Auto-verification successful for user: $userId');
              }
              _setLoading(false);
              notifyListeners(); // Notify UI to update
            } catch (e) {
              print('❌ Error in auto-verification: $e');
              _setError('Auto-verification failed: ${e.toString()}');
              _setLoading(false);
              notifyListeners();
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            print('❌ ========== VERIFICATION FAILED ==========');
            print('❌ Error code: ${e.code}');
            print('❌ Error message: ${e.message}');
            print('❌ Full error: $e');
            
            // For emulator testing, provide helpful error message
            if (e.code == 'invalid-app-credential' || e.message?.contains('Play Integrity') == true) {
              _setError('Emulator detected. Please use test phone number: +919999999999 with OTP: 123456');
            } else {
              _setError('Verification failed: ${e.message}');
            }
            _setLoading(false);
          },
          codeSent: (String verificationId, int? resendToken) {
            print('✅ ========== OTP CODE SENT ==========');
            print('✅ Verification ID received: ${verificationId.substring(0, 20)}...');
            print('✅ Resend token: $resendToken');
            _verificationId = verificationId;
            _setLoading(false);
            notifyListeners(); // Notify UI that OTP is ready for verification
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('⏰ ========== CODE AUTO-RETRIEVAL TIMEOUT ==========');
            print('⏰ Verification ID: ${verificationId.substring(0, 20)}...');
            _verificationId = verificationId;
          },
        );
        
        print('📱 FirebaseService.verifyPhoneNumber call completed');
        print('📱 Error returned: $error');
        
        if (error == null) {
          print('✅ No error - OTP sending initiated successfully');
          return true;
        } else {
          print('❌ Error occurred: $error');
          _setError(error);
          _setLoading(false);
          return false;
        }
      }
      
      print('❌ Unexpected: Reached end of sendOTP without returning');
      _setError('Failed to send OTP. Please check your phone number.');
      _setLoading(false);
      return false;
    } catch (e) {
      print('❌ ========== EXCEPTION IN SEND OTP ==========');
      print('❌ Exception: $e');
      print('❌ Exception type: ${e.runtimeType}');
      print('❌ Stack trace:');
      print(StackTrace.current);
      _setError('Failed to send OTP: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP using Firebase Phone Authentication
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    print('Verifying OTP via Firebase...');
    print('Current verificationId: ${_verificationId ?? "null"}');
    print('Current confirmationResult: ${_confirmationResult != null ? "exists" : "null"}');
    _setLoading(true);
    _clearError();

    try {
      // Check if this is a test phone number for emulator
      if (_isTestPhoneNumber(phoneNumber) && otp == '123456') {
        print('Using test phone number - bypassing Firebase Auth');
        // Create a mock user for testing
        await _createTestUser(phoneNumber);
        _setLoading(false);
        notifyListeners();
        return true;
      }

      UserCredential? userCredential;

      if (kIsWeb) {
        // Web uses ConfirmationResult
        if (_confirmationResult == null) {
          print('Error: confirmationResult is null - OTP session expired');
          _setError('Session expired. Please request OTP again');
          _setLoading(false);
          return false;
        }
        try {
          userCredential = await _confirmationResult!.confirm(otp);
        } catch (e) {
          print('Error confirming OTP on web: $e');
          if (e.toString().contains('invalid-verification-code')) {
            _setError('Invalid OTP. Please check and try again');
          } else if (e.toString().contains('session-expired')) {
            _setError('Session expired. Please request a new OTP');
          } else {
            _setError('Verification failed: ${e.toString()}');
          }
          _setLoading(false);
          return false;
        }
      } else {
        // Mobile uses verificationId
        if (_verificationId == null || _verificationId!.isEmpty) {
          print('Error: verificationId is null or empty - OTP session expired');
          print('This usually means:');
          print('1. OTP was never requested successfully');
          print('2. App was restarted and verification ID was lost');
          print('3. Previous OTP session expired');
          _setError('Session expired. Please request OTP again');
          _setLoading(false);
          return false;
        }
        
        print('Using verificationId: ${_verificationId!.substring(0, 20)}...');
        print('OTP length: ${otp.length}');
        
        try {
          userCredential = await FirebaseService.signInWithPhoneCredential(
            verificationId: _verificationId!,
            smsCode: otp,
          );
          print('Phone credential sign-in successful');
        } catch (e) {
          print('Error in signInWithPhoneCredential: $e');
          
          // Better error messages
          if (e.toString().contains('invalid-verification-code')) {
            _setError('Invalid OTP. Please check the 6-digit code and try again');
          } else if (e.toString().contains('session-expired') || e.toString().contains('network-request-failed')) {
            _setError('Session expired or network issue. Please request a new OTP');
            print('Clearing verification ID due to session expiry');
            _verificationId = null; // Clear expired session
          } else if (e.toString().contains('too-many-requests')) {
            _setError('Too many attempts. Please wait a few minutes and try again');
          } else {
            _setError('Verification failed. Please try requesting a new OTP');
          }
          _setLoading(false);
          return false;
        }
      }
      
      // Check if userCredential is valid
      if (userCredential?.user == null) {
        print('❌ userCredential or user is null');
        _setError('Authentication failed. User credential is null');
        _setLoading(false);
        return false;
      }
      
      final userId = userCredential!.user!.uid;
      print('✅ User authenticated successfully: $userId');
      print('📱 Phone number: ${userCredential.user!.phoneNumber}');
      
      try {
        // Try to load existing user data from Firestore
        print('🔍 Checking for existing user data...');
        final existingData = await FirebaseService.getUserCard(userId);
        
        if (existingData != null) {
          // User exists, load their data
          print('✅ Loading existing user data');
          _currentUser = UserCard.fromMap(existingData);
          print('✅ User data loaded successfully');
        } else {
          // New user, create user card
          print('🆕 Creating new user card');
          _currentUser = UserCard(
            id: userId,
            userId: userId,
            fullName: userCredential.user!.displayName ?? 'User',
            phoneNumber: phoneNumber,
            companyName: 'Company',
            designation: 'Employee',
            companyId: '',
            verificationLevel: VerificationLevel.basic,
            isCompanyVerified: false,
            customerRating: 0.0,
            totalRatings: 0,
            verifiedByColleagues: [],
            createdAt: DateTime.now(),
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            version: 1,
            isActive: true,
            uploadedDocuments: [],
            profilePhotoUrl: userCredential.user!.photoURL,
          );
          
          // Save new user to Firestore with error handling
          print('💾 Saving new user to Firestore...');
          try {
            await _saveUserToFirestore(_currentUser!);
            print('✅ New user saved successfully to Firestore');
          } catch (e) {
            print('❌ Error saving new user to Firestore: $e');
            // Don't fail the entire authentication - user is still authenticated
            print('⚠️ Continuing with authentication despite Firestore save error');
          }
        }
        
        // Set up real-time sync
        print('🔄 Setting up real-time sync...');
        _setupRealtimeSync(userId);
        
        // Trigger automatic migration if needed
        print('🔄 Triggering migration if needed...');
        _triggerMigrationIfNeeded(userId);
        
        // Update FCM token for push notifications
        print('🔔 Updating FCM token...');
        _updateFCMToken(userId);
        
        // Clear verification session
        _verificationId = null;
        _confirmationResult = null;
        
        _setLoading(false);
        print('🎉 Login successful!');
        return true;
        
      } catch (e) {
        print('❌ Error in user data handling: $e');
        // Even if user data handling fails, the user is still authenticated
        // Create a minimal user object to allow login
        _currentUser = UserCard(
          id: userId,
          userId: userId,
          fullName: 'User',
          phoneNumber: phoneNumber,
          companyName: 'Company',
          designation: 'Employee',
          companyId: '',
          verificationLevel: VerificationLevel.basic,
          isCompanyVerified: false,
          customerRating: 0.0,
          totalRatings: 0,
          verifiedByColleagues: [],
          createdAt: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          version: 1,
          isActive: true,
          uploadedDocuments: [],
          profilePhotoUrl: null,
        );
        
        _setLoading(false);
        print('⚠️ Login successful with minimal user data');
        return true;
      }
      
    } catch (e) {
      print('💥 Unexpected error in verifyOTP: $e');
      _setError('An unexpected error occurred. Please try again');
      _setLoading(false);
      return false;
    }
  }

  // Send OTP for linking phone to existing account (doesn't auto-signin)
  Future<bool> sendOTPForLinking(String phoneNumber) async {
    print('Sending OTP for phone linking (no auto-signin)...');
    _setLoading(true);
    _clearError();

    try {
      if (kIsWeb) {
        // Web uses ConfirmationResult
        final confirmationResult = await FirebaseService.signInWithPhoneNumber(phoneNumber);
        if (confirmationResult != null) {
          _confirmationResult = confirmationResult;
          _setLoading(false);
          return true;
        }
      } else {
        // Mobile uses verifyPhoneNumber with callbacks
        // IMPORTANT: verificationCompleted does NOT auto-signin
        final error = await FirebaseService.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // DO NOT sign in - just log that verification was instant
            print('Auto-verification detected but NOT signing in (user is already logged in)');
            // Store the credential for manual verification later
            _setLoading(false);
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Phone verification failed: ${e.message}');
            _setError('Verification failed: ${e.message}');
            _setLoading(false);
          },
          codeSent: (String verificationId, int? resendToken) {
            print('OTP code sent successfully, verificationId: ${verificationId.substring(0, 20)}...');
            _verificationId = verificationId;
            _setLoading(false);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
        
        if (error == null) {
          return true;
        } else {
          _setError(error);
          _setLoading(false);
          return false;
        }
      }
      
      _setError('Failed to send OTP. Please check your phone number.');
      _setLoading(false);
      return false;
    } catch (e) {
      print('Error sending OTP for linking: $e');
      _setError('Failed to send OTP: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP and link phone to existing account (for email users)
  Future<bool> verifyAndLinkPhone(String phoneNumber, String otp) async {
    print('Verifying OTP and linking phone to existing account...');
    _setLoading(true);
    _clearError();

    try {
      // Check if user is logged in
      if (_currentUser == null) {
        _setError('No user logged in');
        _setLoading(false);
        return false;
      }

      // Verify the OTP first
      if (_verificationId == null || _verificationId!.isEmpty) {
        print('Error: verificationId is null or empty');
        _setError('Session expired. Please request OTP again');
        _setLoading(false);
        return false;
      }

      print('Creating phone credential with verificationId and OTP');
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Link the phone credential to existing user
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser == null) {
        _setError('Firebase user not found');
        _setLoading(false);
        return false;
      }

      print('Linking phone credential to existing user...');
      try {
        await currentFirebaseUser.linkWithCredential(phoneCredential);
        print('Phone credential linked successfully');
      } catch (e) {
        print('Error linking credential: $e');
        
        // Better error messages
        if (e.toString().contains('invalid-verification-code')) {
          _setError('Invalid OTP. Please check the 6-digit code and try again');
        } else if (e.toString().contains('credential-already-in-use')) {
          _setError('This phone number is already registered with another account');
        } else if (e.toString().contains('session-expired')) {
          _setError('Session expired. Please request a new OTP');
          _verificationId = null;
        } else {
          _setError('Failed to verify phone: ${e.toString()}');
        }
        _setLoading(false);
        return false;
      }

      // Update the user's phone number in local data
      _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
      
      // Save to Firestore
      await _saveUserToFirestore(_currentUser!);
      
      // Clear verification session
      _verificationId = null;
      
      print('Phone number updated successfully in user profile');
      _setLoading(false);
      return true;
    } catch (e) {
      print('Unexpected error in verifyAndLinkPhone: $e');
      _setError('An unexpected error occurred. Please try again');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

         // Email/Password Authentication
         Future<bool> signInWithEmailAndPassword(String email, String password) async {
           _setLoading(true);
           _clearError();

           try {
             final userCredential = await FirebaseService.signInWithEmailAndPassword(email, password);
             
             if (userCredential != null && userCredential.user != null) {
               // User-driven app - no admin system
               
               // Create user card from Firebase user data
               // Check if this is an email user (no phone number) and fix existing users
               String phoneNumber = '';
               if (userCredential.user!.phoneNumber != null && 
                   userCredential.user!.phoneNumber!.contains('@')) {
                 // This is an existing user with email as phone number - fix it
                 phoneNumber = '';
                 print('DEBUG: Fixed existing user - removed email from phone number');
               }
               
               _currentUser = UserCard(
                 id: userCredential.user!.uid,
                 userId: userCredential.user!.uid,
                 fullName: userCredential.user!.displayName ?? 'User',
                 phoneNumber: phoneNumber, // Email users don't have phone numbers initially
                 companyName: 'Company',
                 designation: 'Employee',
                 companyId: '',
                 verificationLevel: VerificationLevel.basic,
                 isCompanyVerified: false,
                 customerRating: 0.0,
                 totalRatings: 0,
                 verifiedByColleagues: [],
                 createdAt: DateTime.now(),
                 expiryDate: DateTime.now().add(const Duration(days: 365)),
                 version: 1,
                 isActive: true,
                 uploadedDocuments: [],
                 profilePhotoUrl: userCredential.user!.photoURL,
               );
               
               _setLoading(false);
               return true;
             } else {
               _setError('Invalid email or password');
               _setLoading(false);
               return false;
             }
           } catch (e) {
             _setError('Sign in failed: ${e.toString()}');
             _setLoading(false);
             return false;
           }
         }

         // Removed admin system - app is user-driven

  Future<bool> createUserWithEmailAndPassword(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await FirebaseService.createUserWithEmailAndPassword(email, password);
      
      if (userCredential != null && userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(fullName);
        
        // Create user card from Firebase user data
        // Check if this is an email user (no phone number) and fix existing users
        String phoneNumber = '';
        if (userCredential.user!.phoneNumber != null && 
            userCredential.user!.phoneNumber!.contains('@')) {
          // This is an existing user with email as phone number - fix it
          phoneNumber = '';
          print('DEBUG: Fixed existing user - removed email from phone number');
        }
        
        _currentUser = UserCard(
          id: userCredential.user!.uid,
          userId: userCredential.user!.uid,
          fullName: fullName,
          phoneNumber: phoneNumber, // Email users don't have phone numbers initially
          companyName: 'Company',
          designation: 'Employee',
          companyId: '',
          verificationLevel: VerificationLevel.basic,
          isCompanyVerified: false,
          customerRating: 0.0,
          totalRatings: 0,
          verifiedByColleagues: [],
          createdAt: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          version: 1,
          isActive: true,
          uploadedDocuments: [],
          profilePhotoUrl: userCredential.user!.photoURL,
        );
        
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Account creation failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Add phone number verification for existing email users
  Future<bool> verifyPhoneForEmailUser(String phoneNumber) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // For email users, we need to link their phone number to their existing account
      // This requires updating the Firebase user's phone number
      final currentFirebaseUser = FirebaseService.getCurrentUser();
      if (currentFirebaseUser == null) {
        _setError('No Firebase user found');
        _setLoading(false);
        return false;
      }

      // Update the user's phone number in Firebase Auth
      await currentFirebaseUser.updatePhoneNumber(
        await FirebaseService.getPhoneAuthCredential(phoneNumber)
      );

      // Update our local user data
      _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Phone verification failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Mock OTP verification for testing (accepts 1234 as valid OTP)
  Future<bool> verifyPhoneWithMockOTP(String phoneNumber, String otp) async {
    print('DEBUG: verifyPhoneWithMockOTP called with phone: $phoneNumber, OTP: $otp');
    
    if (_currentUser == null) {
      print('DEBUG: No user logged in');
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Mock OTP verification - accept 123456 as valid
      if (otp == '123456') {
        print('DEBUG: OTP is valid, updating user phone number');
        // Update our local user data with phone number
        _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
        
        _setLoading(false);
        print('DEBUG: Phone verification successful');
        return true;
      } else {
        print('DEBUG: Invalid OTP: $otp');
        _setError('Invalid OTP. Please enter 123456 for testing.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('DEBUG: Error in phone verification: $e');
      _setError('Phone verification failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Check if phone number is a test number for emulator
  bool _isTestPhoneNumber(String phoneNumber) {
    // Only allow test OTP for the specific test number 8888888888
    final normalizedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    return normalizedPhone == '8888888888';
  }

  // Create a test user for emulator testing
  Future<void> _createTestUser(String phoneNumber) async {
    try {
      final testUserId = 'test_user_${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}';
      
      _currentUser = UserCard(
        id: testUserId,
        userId: testUserId,
        fullName: 'Test User',
        phoneNumber: phoneNumber,
        companyName: 'Test Company',
        designation: 'Test Role',
        companyId: 'test_company_id',
        verificationLevel: VerificationLevel.basic,
        isCompanyVerified: false,
        customerRating: 0.0,
        totalRatings: 0,
        verifiedByColleagues: [],
        createdAt: DateTime.now(),
        version: 1,
        isActive: true,
      );
      
      // Save to Firebase
      await FirebaseService.saveUserCard(testUserId, _currentUser!.toMap());
      _setupRealtimeSync(testUserId);
      
      print('Test user created successfully: $testUserId');
    } catch (e) {
      print('Error creating test user: $e');
    }
  }
}
