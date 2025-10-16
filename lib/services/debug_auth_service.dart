import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Debug the complete authentication flow
  static Future<Map<String, dynamic>> debugAuthFlow(String phoneNumber, String otp) async {
    Map<String, dynamic> result = {
      'success': false,
      'error': null,
      'logs': <String>[],
      'userCredential': null,
      'firebaseUser': null,
      'userData': null,
    };
    
    try {
      result['logs'].add('🚀 Starting debug authentication flow');
      result['logs'].add('📱 Phone: $phoneNumber');
      result['logs'].add('🔑 OTP: $otp');
      
      // Check current Firebase user
      final currentUser = _auth.currentUser;
      result['logs'].add('👤 Current Firebase user: ${currentUser?.uid ?? "null"}');
      
      // Check if user is already signed in
      if (currentUser != null) {
        result['logs'].add('⚠️ User already signed in, signing out first');
        await _auth.signOut();
        result['logs'].add('✅ Signed out successfully');
      }
      
      // Try to verify phone number and get verification ID
      result['logs'].add('📤 Attempting phone verification...');
      
      String? verificationId;
      bool verificationStarted = false;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          result['logs'].add('✅ Auto-verification completed');
          result['success'] = true;
        },
        verificationFailed: (FirebaseAuthException e) {
          result['logs'].add('❌ Verification failed: ${e.code} - ${e.message}');
          result['error'] = '${e.code}: ${e.message}';
        },
        codeSent: (String vid, int? resendToken) {
          result['logs'].add('✅ OTP sent successfully');
          result['logs'].add('🆔 Verification ID: ${vid.substring(0, 20)}...');
          verificationId = vid;
          verificationStarted = true;
        },
        codeAutoRetrievalTimeout: (String vid) {
          result['logs'].add('⏰ Auto-retrieval timeout');
          verificationId = vid;
        },
        timeout: const Duration(seconds: 60),
      );
      
      // Wait for verification to start
      await Future.delayed(const Duration(seconds: 2));
      
      if (!verificationStarted) {
        result['logs'].add('❌ Phone verification did not start');
        result['error'] = 'Phone verification failed to start';
        return result;
      }
      
      if (verificationId == null) {
        result['logs'].add('❌ No verification ID received');
        result['error'] = 'No verification ID received';
        return result;
      }
      
      // Now try to verify the OTP
      result['logs'].add('🔍 Verifying OTP with verification ID...');
      
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: otp,
        );
        
        result['logs'].add('🔑 Credential created successfully');
        
        final userCredential = await _auth.signInWithCredential(credential);
        result['logs'].add('✅ User credential sign-in successful');
        result['userCredential'] = {
          'uid': userCredential.user?.uid,
          'phoneNumber': userCredential.user?.phoneNumber,
          'isEmailVerified': userCredential.user?.emailVerified,
        };
        
        final firebaseUser = userCredential.user;
        result['firebaseUser'] = {
          'uid': firebaseUser?.uid,
          'phoneNumber': firebaseUser?.phoneNumber,
          'displayName': firebaseUser?.displayName,
          'email': firebaseUser?.email,
          'isAnonymous': firebaseUser?.isAnonymous,
          'metadata': {
            'creationTime': firebaseUser?.metadata.creationTime?.toIso8601String(),
            'lastSignInTime': firebaseUser?.metadata.lastSignInTime?.toIso8601String(),
          },
        };
        
        // Try to get user data from Firestore
        if (firebaseUser != null) {
          result['logs'].add('🔍 Checking Firestore for user data...');
          
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(firebaseUser.uid)
                .get();
            
            if (userDoc.exists) {
              result['logs'].add('✅ User data found in Firestore');
              result['userData'] = userDoc.data();
            } else {
              result['logs'].add('⚠️ No user data found in Firestore');
              result['userData'] = null;
            }
          } catch (e) {
            result['logs'].add('❌ Error accessing Firestore: $e');
          }
        }
        
        result['success'] = true;
        result['logs'].add('🎉 Authentication flow completed successfully');
        
      } catch (e) {
        result['logs'].add('❌ Error in credential verification: $e');
        result['error'] = e.toString();
      }
      
    } catch (e) {
      result['logs'].add('💥 Exception in debug flow: $e');
      result['error'] = e.toString();
    }
    
    return result;
  }
  
  /// Get detailed Firebase configuration
  static Map<String, dynamic> getFirebaseConfig() {
    return {
      'projectId': _auth.app.options.projectId,
      'apiKey': _auth.app.options.apiKey?.substring(0, 10) + '...',
      'appId': _auth.app.options.appId,
      'messagingSenderId': _auth.app.options.messagingSenderId,
      'storageBucket': _auth.app.options.storageBucket,
      'authDomain': _auth.app.options.authDomain,
    };
  }
}
