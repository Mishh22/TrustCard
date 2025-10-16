import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AccountLifecycleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track card creation
  static Future<void> trackCardCreation(String userId, String cardId) async {
    try {
      final deviceId = await _getDeviceId();
      final ipAddress = await _getIPAddress();
      
      await _firestore.collection('account_lifecycle').add({
        'userId': userId,
        'cardId': cardId,
        'action': 'created',
        'timestamp': FieldValue.serverTimestamp(),
        'deviceId': deviceId,
        'ipAddress': ipAddress,
        'metadata': {
          'platform': Platform.operatingSystem,
          'version': Platform.version,
        }
      });
    } catch (e) {
      print("Error tracking card creation: $e");
    }
  }
  
  // Track card deletion
  static Future<void> trackCardDeletion(String userId, String cardId, double finalTrustScore, int totalRatings) async {
    try {
      final deviceId = await _getDeviceId();
      final ipAddress = await _getIPAddress();
      
      await _firestore.collection('account_lifecycle').add({
        'userId': userId,
        'cardId': cardId,
        'action': 'deleted',
        'timestamp': FieldValue.serverTimestamp(),
        'reasonCode': 'user_initiated',
        'finalTrustScore': finalTrustScore,
        'totalRatings': totalRatings,
        'deviceId': deviceId,
        'ipAddress': ipAddress,
        'metadata': {
          'platform': Platform.operatingSystem,
          'version': Platform.version,
        }
      });
    } catch (e) {
      print("Error tracking card deletion: $e");
    }
  }
  
  // Check if user can create new card (velocity and cooldown checks)
  static Future<bool> canCreateNewCard(String userId) async {
    try {
      // Check deletion velocity (last 30 days)
      final deletions = await _firestore
          .collection('account_lifecycle')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'deleted')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      
      final recentDeletions = deletions.docs.where((doc) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        return DateTime.now().difference(timestamp).inDays <= 30;
      }).length;
      
      if (recentDeletions >= 3) {
        // Flagged: User deleted 3+ cards in 30 days
        await _flagSuspiciousActivity(userId, 'excessive_card_deletion');
        return false;
      }
      
      // Check cooldown period
      if (deletions.docs.isNotEmpty) {
        final lastDeletion = deletions.docs.first;
        final deletionTime = (lastDeletion.data()['timestamp'] as Timestamp).toDate();
        final hoursSinceDeletion = DateTime.now().difference(deletionTime).inHours;
        
        // Get lifetime deletion count
        final deletionCount = await _getLifetimeDeletionCount(userId);
        int requiredCooldownHours;
        
        if (deletionCount == 1) {
          requiredCooldownHours = 24;    // 1st deletion: 24 hour cooldown
        } else if (deletionCount == 2) {
          requiredCooldownHours = 72;    // 2nd deletion: 3 day cooldown
        } else if (deletionCount >= 3) {
          requiredCooldownHours = 168;   // 3+ deletions: 7 day cooldown
        } else {
          return true; // No previous deletions
        }
        
        if (hoursSinceDeletion < requiredCooldownHours) {
          return false; // Still in cooldown period
        }
      }
      
      // Check device fingerprinting
      final deviceId = await _getDeviceId();
      if (await isDeviceFlagged(deviceId)) {
        return false;
      }
      
      return true;
    } catch (e) {
      print("Error checking card creation eligibility: $e");
      return true; // Allow creation on error to avoid blocking legitimate users
    }
  }
  
  // Get deletion count for trust score calculation
  static Future<int> getDeletionCount(String userId) async {
    try {
      final deletionHistory = await _firestore
          .collection('account_lifecycle')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'deleted')
          .get();
      
      return deletionHistory.docs.length;
    } catch (e) {
      print("Error getting deletion count: $e");
      return 0;
    }
  }
  
  // Get suspicious deletion patterns
  static Future<int> getSuspiciousDeletionCount(String userId) async {
    try {
      final deletionHistory = await _firestore
          .collection('account_lifecycle')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'deleted')
          .get();
      
      // Count deletions with low trust score and multiple ratings (suspicious pattern)
      return deletionHistory.docs.where((doc) {
        final finalScore = doc.data()['finalTrustScore'] ?? 0;
        final ratings = doc.data()['totalRatings'] ?? 0;
        return finalScore < 40 && ratings >= 5; // Deleted after getting bad reviews
      }).length;
    } catch (e) {
      print("Error getting suspicious deletion count: $e");
      return 0;
    }
  }
  
  // Calculate initial trust score with deletion penalties
  static Future<double> calculateInitialTrustScore(String userId) async {
    try {
      final deletionCount = await getDeletionCount(userId);
      final suspiciousDeletions = await getSuspiciousDeletionCount(userId);
      
      // Base trust score for new card
      double initialScore = 20.0; // Basic phone verification
      
      // Apply escalating penalties for repeated deletions
      if (deletionCount == 1) {
        initialScore -= 5.0;   // 1st recreation: -5 points
      } else if (deletionCount == 2) {
        initialScore -= 10.0;  // 2nd recreation: -10 points
      } else if (deletionCount >= 3) {
        initialScore -= 20.0;  // 3+ recreations: -20 points (starts at 0)
      }
      
      // Heavy penalty for deleting after bad reviews
      if (suspiciousDeletions > 0) {
        initialScore -= (suspiciousDeletions * 10);
      }
      
      return initialScore.clamp(0.0, 20.0); // New accounts capped at 20 regardless
    } catch (e) {
      print("Error calculating initial trust score: $e");
      return 20.0; // Default score on error
    }
  }
  
  // Device fingerprinting
  static Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Android ID (resets on factory reset)
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? ''; // iOS vendor ID
      }
      return 'unknown';
    } catch (e) {
      print("Error getting device ID: $e");
      return 'unknown';
    }
  }
  
  // Check if device is flagged for excessive account creation
  static Future<bool> isDeviceFlagged(String deviceId) async {
    try {
      final deviceCards = await _firestore
          .collection('account_lifecycle')
          .where('deviceId', isEqualTo: deviceId)
          .where('action', isEqualTo: 'created')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      // Count card creations from this device in last 30 days
      final recentCreations = deviceCards.docs.where((doc) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        return DateTime.now().difference(timestamp).inDays <= 30;
      }).length;
      
      if (recentCreations > 5) {
        // Same device created 5+ cards in 30 days - highly suspicious
        await _flagDevice(deviceId, 'excessive_account_creation');
        return true;
      }
      
      return false;
    } catch (e) {
      print("Error checking device flag: $e");
      return false;
    }
  }
  
  // Get IP address (simplified - in production use proper IP detection)
  static Future<String> _getIPAddress() async {
    try {
      // In production, you would use a service to get the actual IP
      // For now, return a placeholder
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  // Get lifetime deletion count
  static Future<int> _getLifetimeDeletionCount(String userId) async {
    try {
      final deletionHistory = await _firestore
          .collection('account_lifecycle')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'deleted')
          .get();
      
      return deletionHistory.docs.length;
    } catch (e) {
      print("Error getting lifetime deletion count: $e");
      return 0;
    }
  }
  
  // Flag suspicious activity
  static Future<void> _flagSuspiciousActivity(String userId, String reason) async {
    try {
      await _firestore.collection('flagged_users').doc(userId).set({
        'userId': userId,
        'reason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'status': 'pending_review',
        'autoDetected': true,
      }, SetOptions(merge: true));
      
      // Temporarily suspend card creation ability
      await _firestore.collection('users').doc(userId).update({
        'canCreateCards': false,
        'suspensionReason': reason,
      });
      
      print("Flagged user $userId for $reason");
    } catch (e) {
      print("Error flagging suspicious activity: $e");
    }
  }
  
  // Flag device
  static Future<void> _flagDevice(String deviceId, String reason) async {
    try {
      await _firestore.collection('flagged_devices').doc(deviceId).set({
        'deviceId': deviceId,
        'reason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));
      
      print("Flagged device $deviceId for $reason");
    } catch (e) {
      print("Error flagging device: $e");
    }
  }
  
  // Admin functions
  static Future<void> adminReviewUser(String userId, bool approved) async {
    try {
      if (approved) {
        await _firestore.collection('users').doc(userId).update({
          'canCreateCards': true,
          'suspensionReason': null,
        });
        await _firestore.collection('flagged_users').doc(userId).update({
          'status': 'cleared',
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Permanently ban user
        await _firestore.collection('flagged_users').doc(userId).update({
          'status': 'banned',
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error in admin review: $e");
    }
  }
}
