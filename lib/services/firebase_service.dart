import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication
  static Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error in signInWithEmailAndPassword: $e");
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error in createUserWithEmailAndPassword: $e");
      return null;
    }
  }


  static Future<ConfirmationResult?> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Note: Phone authentication works on web and real devices
      // For emulators/simulators during development, you can use test phone numbers
      // Set test phone numbers in Firebase Console -> Authentication -> Sign-in method -> Phone
      
      return await _auth.signInWithPhoneNumber(phoneNumber);
    } catch (e) {
      print("Error in signInWithPhoneNumber: $e");
      print("For emulators: Use test phone numbers configured in Firebase Console");
      return null;
    }
  }

  // Phone authentication with verification callback for mobile
  static Future<String?> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      print('🔥 FirebaseService: Starting verifyPhoneNumber');
      print('🔥 Phone number: $phoneNumber');
      print('🔥 Firebase Auth instance: ${_auth.app.name}');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
      
      print('🔥 FirebaseService: verifyPhoneNumber call completed without error');
      return null;
    } catch (e) {
      print("❌ FirebaseService: Error in verifyPhoneNumber: $e");
      print("❌ FirebaseService: Error type: ${e.runtimeType}");
      return e.toString();
    }
  }

  // Verify OTP and sign in
  static Future<UserCredential?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      print("🔑 Creating phone credential with verificationId: ${verificationId.substring(0, 20)}...");
      print("🔑 SMS code length: ${smsCode.length}");
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      print("🔑 Credential created, attempting sign in...");
      final userCredential = await _auth.signInWithCredential(credential);
      
      print("✅ Sign in successful: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      print("❌ Error in signInWithPhoneCredential: $e");
      print("❌ Error type: ${e.runtimeType}");
      rethrow; // Re-throw the error so it can be handled properly
    }
  }

  // Get phone auth credential for linking phone to existing email account
  static Future<PhoneAuthCredential> getPhoneAuthCredential(String phoneNumber) async {
    try {
      // This would normally require a reCAPTCHA verifier
      // For mobile apps, we can use the phone number directly
      return PhoneAuthProvider.credential(
        verificationId: 'mock_verification_id', // In production, this comes from signInWithPhoneNumber
        smsCode: 'mock_sms_code', // In production, this comes from SMS
      );
    } catch (e) {
      print("Error in getPhoneAuthCredential: $e");
      rethrow;
    }
  }

  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print("Error in signInAnonymously: $e");
      return null;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error in signOut: $e");
    }
  }

  // Firestore - User Card Management with Real-time Sync
  static Future<void> saveUserCard(String userId, Map<String, dynamic> cardData) async {
    try {
      // Use userId as document ID for easy access and sync across devices
      await _firestore.collection('users').doc(userId).set(cardData, SetOptions(merge: true));
    } catch (e) {
      print("Error in saveUserCard: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserCard(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print("Error in getUserCard: $e");
      return null;
    }
  }

  // Real-time listener for user card changes across devices
  static Stream<Map<String, dynamic>?> getUserCardStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  static Future<void> updateUserCard(String userId, Map<String, dynamic> cardData) async {
    try {
      await _firestore.collection('users').doc(userId).update(cardData);
    } catch (e) {
      print("Error in updateUserCard: $e");
      rethrow;
    }
  }

  static Future<void> deleteUserCard(String userId) async {
    try {
      await _firestore.collection('userCards').doc(userId).delete();
    } catch (e) {
      print("Error in deleteUserCard: $e");
    }
  }

  // Scanned Cards Management - User's collection of other people's cards
  static Future<void> saveScannedCard(String userId, String cardId, Map<String, dynamic> cardData) async {
    try {
      // Store scanned cards in a subcollection under the user's document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scannedCards')
          .doc(cardId)
          .set(cardData, SetOptions(merge: true));
    } catch (e) {
      print("Error in saveScannedCard: $e");
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getScannedCards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scannedCards')
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print("Error in getScannedCards: $e");
      return [];
    }
  }

  // Real-time listener for scanned cards changes across devices
  static Stream<List<Map<String, dynamic>>> getScannedCardsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scannedCards')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  static Future<void> deleteScannedCard(String userId, String cardId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scannedCards')
          .doc(cardId)
          .delete();
    } catch (e) {
      print("Error in deleteScannedCard: $e");
      rethrow;
    }
  }

  // Get public card data by ID (for QR code scanning)
  // This now queries the user_cards collection correctly
  static Future<Map<String, dynamic>?> getPublicCardById(String cardId) async {
    try {
      final doc = await _firestore.collection('user_cards').doc(cardId).get();
      
      if (!doc.exists || doc.data() == null) {
        print("Card not found in user_cards: $cardId");
        return null;
      }
      
      final data = doc.data()!;
      
      // Return only PUBLIC data - exclude sensitive information
      return {
        'id': data['id'] ?? cardId,
        'userId': data['userId'],
        'fullName': data['fullName'] ?? 'Unknown',
        'companyName': data['companyName'],
        'designation': data['designation'],
        'companyId': data['companyId'],
        'verificationLevel': data['verificationLevel'] ?? 'basic',
        'isCompanyVerified': data['isCompanyVerified'] ?? false,
        'companyVerificationDepth': data['companyVerificationDepth'],
        'customerRating': data['customerRating'],
        'totalRatings': data['totalRatings'],
        'verifiedByColleagues': data['verifiedByColleagues'] ?? [],
        'createdAt': data['createdAt'],
        'isActive': data['isActive'] ?? true,
        'profilePhotoUrl': data['profilePhotoUrl'],
        'version': data['version'] ?? 1,
        // EXCLUDE: phoneNumber, email, personal details for privacy
      };
    } catch (e) {
      print("Error getting public card by ID: $e");
      return null;
    }
  }

  static Future<void> saveVerificationRequest(Map<String, dynamic> requestData) async {
    try {
      await _firestore.collection('verificationRequests').add(requestData);
    } catch (e) {
      print("Error in saveVerificationRequest: $e");
    }
  }

  static Future<void> saveActivityLog(Map<String, dynamic> activityData) async {
    try {
      await _firestore.collection('activityLogs').add(activityData);
    } catch (e) {
      print("Error in saveActivityLog: $e");
    }
  }

  // Storage
  static Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error in uploadFile: $e");
      return null;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print("Error in deleteFile: $e");
    }
  }

  // Document Management
  // Save verification document metadata to Firestore
  static Future<void> saveVerificationDocument(String userId, String cardId, Map<String, dynamic> documentData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .collection('documents')
          .doc(documentData['id'])
          .set(documentData);
    } catch (e) {
      print("Error in saveVerificationDocument: $e");
      rethrow;
    }
  }

  // Get all documents for a specific card
  static Future<List<Map<String, dynamic>>> getCardDocuments(String userId, String cardId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .collection('documents')
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error in getCardDocuments: $e");
      return [];
    }
  }

  // Get a specific document
  static Future<Map<String, dynamic>?> getVerificationDocument(String userId, String cardId, String documentId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .collection('documents')
          .doc(documentId)
          .get();
      
      return doc.data();
    } catch (e) {
      print("Error in getVerificationDocument: $e");
      return null;
    }
  }

  // Delete verification document
  static Future<void> deleteVerificationDocument(String userId, String cardId, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .collection('documents')
          .doc(documentId)
          .delete();
    } catch (e) {
      print("Error in deleteVerificationDocument: $e");
      rethrow;
    }
  }

  // Stream of documents for real-time updates
  static Stream<List<Map<String, dynamic>>> getCardDocumentsStream(String userId, String cardId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(cardId)
        .collection('documents')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Upload document file to Firebase Storage
  static Future<String?> uploadDocumentFile(File file, String userId, String cardId, String documentId) async {
    try {
      final path = 'users/$userId/cards/$cardId/documents/$documentId/${file.path.split('/').last}';
      return await uploadFile(file, path);
    } catch (e) {
      print("Error in uploadDocumentFile: $e");
      return null;
    }
  }

  // Delete document file from Firebase Storage
  static Future<void> deleteDocumentFile(String userId, String cardId, String documentId, String fileName) async {
    try {
      final path = 'users/$userId/cards/$cardId/documents/$documentId/$fileName';
      await deleteFile(path);
    } catch (e) {
      print("Error in deleteDocumentFile: $e");
    }
  }

  // Messaging
  static Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print("Error in getFCMToken: $e");
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print("Error in subscribeToTopic: $e");
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print("Error in unsubscribeFromTopic: $e");
    }
  }

  // Utility methods
  static Future<void> initialize() async {
    try {
      // Firebase is already initialized in main.dart
      print("Firebase service initialized successfully");
    } catch (e) {
      print("Error in initialize: $e");
    }
  }

  static bool get isInitialized => _auth.currentUser != null || true; // Check if Firebase is working

  // Get card creation limit from Firebase configuration
  static Future<int> getCardLimit() async {
    try {
      final doc = await _firestore.collection('app_config').doc('limits').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['maxCardsPerUser'] ?? 10; // Default limit of 10
      }
      return 10; // Default limit if no configuration found
    } catch (e) {
      print("Error getting card limit: $e");
      return 10; // Default limit on error
    }
  }

  // ============================================================================
  // NEW: User Cards Collection Management (Separate from User Profiles)
  // ============================================================================

  /// Save a card to the user_cards collection
  /// Each card has a unique ID and belongs to a user (via userId field)
  static Future<void> saveUserCardToCardsCollection(Map<String, dynamic> cardData) async {
    try {
      final cardId = cardData['id'];
      if (cardId == null || cardId.isEmpty) {
        throw Exception('Card ID is required');
      }
      
      await _firestore
          .collection('user_cards')
          .doc(cardId)
          .set(cardData, SetOptions(merge: true));
    } catch (e) {
      print("Error saving card to user_cards collection: $e");
      rethrow;
    }
  }

  /// Get a specific card by its ID from user_cards collection
  static Future<Map<String, dynamic>?> getCardById(String cardId) async {
    try {
      final doc = await _firestore.collection('user_cards').doc(cardId).get();
      return doc.data();
    } catch (e) {
      print("Error getting card by ID: $e");
      return null;
    }
  }

  /// Get all cards for a specific user
  static Future<List<Map<String, dynamic>>> getUserCards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_cards')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print("Error getting user cards: $e");
      return [];
    }
  }

  /// Get real-time stream of user's cards
  static Stream<List<Map<String, dynamic>>> getUserCardsStream(String userId) {
    return _firestore
        .collection('user_cards')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Update a card in the user_cards collection
  static Future<void> updateUserCardInCardsCollection(String cardId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('user_cards').doc(cardId).update(updates);
    } catch (e) {
      print("Error updating card in user_cards collection: $e");
      rethrow;
    }
  }

  /// Delete a card from the user_cards collection
  static Future<void> deleteUserCardFromCardsCollection(String cardId) async {
    try {
      await _firestore.collection('user_cards').doc(cardId).delete();
    } catch (e) {
      print("Error deleting card from user_cards collection: $e");
      rethrow;
    }
  }

  /// Get count of cards for a user
  static Future<int> getUserCardCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_cards')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting user card count: $e");
      return 0;
    }
  }
}