import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Service for managing user profiles
/// Profiles contain account information, separate from digital cards
class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or update user profile
  static Future<void> saveProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error saving profile: $e");
      rethrow;
    }
  }

  /// Get user profile by ID
  static Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return UserProfile.fromMap(doc.data()!);
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  /// Get real-time profile stream
  static Stream<UserProfile?> getProfileStream(String userId) {
    return _firestore
        .collection('user_profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }
          return UserProfile.fromMap(snapshot.data()!);
        });
  }

  /// Update profile fields
  static Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .update(updates);
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  /// Update last login time
  static Future<void> updateLastLogin(String userId) async {
    try {
      await updateProfile(userId, {
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error updating last login: $e");
    }
  }

  /// Update FCM token for push notifications
  static Future<void> updateFCMToken(String userId, String token) async {
    try {
      await updateProfile(userId, {'fcmToken': token});
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  /// Delete user profile
  static Future<void> deleteProfile(String userId) async {
    try {
      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .delete();
    } catch (e) {
      print("Error deleting profile: $e");
      rethrow;
    }
  }

  /// Check if profile exists
  static Future<bool> profileExists(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print("Error checking profile existence: $e");
      return false;
    }
  }
}

