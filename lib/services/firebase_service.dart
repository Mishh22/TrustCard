// Firebase service temporarily disabled for iOS compatibility
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class FirebaseService {
  // Firebase services temporarily disabled for iOS compatibility
  // static final FirebaseAuth _auth = FirebaseAuth.instance;
  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final FirebaseStorage _storage = FirebaseStorage.instance;
  // static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication
  static Future<dynamic> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Stub implementation for development
      print("Firebase Auth disabled - using stub implementation");
      return null;
    } catch (e) {
      print("Error in signInWithPhoneNumber: $e");
      return null;
    }
  }

  static Future<dynamic> signInAnonymously() async {
    try {
      // Stub implementation for development
      print("Firebase Auth disabled - using stub implementation");
      return null;
    } catch (e) {
      print("Error in signInAnonymously: $e");
      return null;
    }
  }

  static dynamic getCurrentUser() {
    // Stub implementation for development
    print("Firebase Auth disabled - using stub implementation");
    return null;
  }

  static Future<void> signOut() async {
    try {
      // Stub implementation for development
      print("Firebase Auth disabled - using stub implementation");
    } catch (e) {
      print("Error in signOut: $e");
    }
  }

  // Firestore
  static Future<void> saveUserCard(Map<String, dynamic> cardData) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
    } catch (e) {
      print("Error in saveUserCard: $e");
    }
  }

  static Future<Map<String, dynamic>?> getUserCard(String userId) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
      return null;
    } catch (e) {
      print("Error in getUserCard: $e");
      return null;
    }
  }

  static Future<void> updateUserCard(String userId, Map<String, dynamic> cardData) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
    } catch (e) {
      print("Error in updateUserCard: $e");
    }
  }

  static Future<void> deleteUserCard(String userId) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
    } catch (e) {
      print("Error in deleteUserCard: $e");
    }
  }

  static Future<void> saveVerificationRequest(Map<String, dynamic> requestData) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
    } catch (e) {
      print("Error in saveVerificationRequest: $e");
    }
  }

  static Future<void> saveActivityLog(Map<String, dynamic> activityData) async {
    try {
      // Stub implementation for development
      print("Firebase Firestore disabled - using stub implementation");
    } catch (e) {
      print("Error in saveActivityLog: $e");
    }
  }

  // Storage
  static Future<String?> uploadFile(File file, String path) async {
    try {
      // Stub implementation for development
      print("Firebase Storage disabled - using stub implementation");
      return null;
    } catch (e) {
      print("Error in uploadFile: $e");
      return null;
    }
  }

  static Future<void> deleteFile(String path) async {
    try {
      // Stub implementation for development
      print("Firebase Storage disabled - using stub implementation");
    } catch (e) {
      print("Error in deleteFile: $e");
    }
  }

  // Messaging
  static Future<String?> getFCMToken() async {
    try {
      // Stub implementation for development
      print("Firebase Messaging disabled - using stub implementation");
      return null;
    } catch (e) {
      print("Error in getFCMToken: $e");
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      // Stub implementation for development
      print("Firebase Messaging disabled - using stub implementation");
    } catch (e) {
      print("Error in subscribeToTopic: $e");
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // Stub implementation for development
      print("Firebase Messaging disabled - using stub implementation");
    } catch (e) {
      print("Error in unsubscribeFromTopic: $e");
    }
  }

  // Utility methods
  static Future<void> initialize() async {
    try {
      // Stub implementation for development
      print("Firebase initialization disabled - using stub implementation");
    } catch (e) {
      print("Error in initialize: $e");
    }
  }

  static bool get isInitialized => true; // Always return true for stub implementation
}