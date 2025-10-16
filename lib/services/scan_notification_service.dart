import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/scan_record.dart';
import '../utils/logger.dart';

/// Service for managing scan notifications
class ScanNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send notification to card owner when their card is scanned
  static Future<bool> sendScanNotification({
    required String cardOwnerId,
    required String scannerName,
    required String scannerCompany,
    required String cardId,
    String? location,
  }) async {
    try {
      final notificationId = _firestore.collection('scan_notifications').doc().id;
      
      final notification = {
        'id': notificationId,
        'userId': cardOwnerId,
        'type': 'card_scanned',
        'title': 'Your Card Was Scanned',
        'message': '$scannerName from $scannerCompany scanned your card',
        'cardId': cardId,
        'scannerName': scannerName,
        'scannerCompany': scannerCompany,
        'location': location,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'cardId': cardId,
          'scannerName': scannerName,
          'scannerCompany': scannerCompany,
          'location': location,
        },
      };

      await _firestore.collection('scan_notifications').doc(notificationId).set(notification);
      
      // Send push notification
      await _sendPushNotification(cardOwnerId, notification['title'] as String, notification['message'] as String, notification);
      
      Logger.success('Scan notification sent to user: $cardOwnerId');
      return true;
    } catch (e) {
      Logger.error('Error sending scan notification: $e');
      return false;
    }
  }

  /// Get scan notifications for a user
  static Future<List<Map<String, dynamic>>> getScanNotifications(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_notifications')
          .where('userId', isEqualTo: userId)
          .limit(limit * 2) // Get more records to sort client-side
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => {
            'id': doc.id,
            ...doc.data(),
          })
          .toList();
      
      // Sort client-side by createdAt descending
      notifications.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      
      // Return limited results
      return notifications.take(limit).toList();
    } catch (e) {
      Logger.error('Error getting scan notifications: $e');
      return [];
    }
  }

  /// Get scan notifications stream for real-time updates
  static Stream<List<Map<String, dynamic>>> getScanNotificationsStream(String userId, {int limit = 50}) {
    return _firestore
        .collection('scan_notifications')
        .where('userId', isEqualTo: userId)
        .limit(limit * 2) // Get more records to sort client-side
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
              .toList();
          
          // Sort client-side by createdAt descending
          notifications.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          
          // Return limited results
          return notifications.take(limit).toList();
        });
  }

  /// Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('scan_notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      Logger.success('Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      Logger.error('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for a user
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      
      Logger.success('All notifications marked as read for user: $userId');
      return true;
    } catch (e) {
      Logger.error('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('scan_notifications')
          .doc(notificationId)
          .delete();
      
      Logger.success('Notification deleted: $notificationId');
      return true;
    } catch (e) {
      Logger.error('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications for a user
  static Future<bool> deleteAllNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      Logger.success('All notifications deleted for user: $userId');
      return true;
    } catch (e) {
      Logger.error('Error deleting all notifications: $e');
      return false;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      Logger.error('Error getting unread count: $e');
      return 0;
    }
  }

  /// Get unread notification count stream
  static Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('scan_notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Send push notification to user
  static Future<void> _sendPushNotification(
    String userId,
    String title,
    String message,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      // Get user's FCM token from profile
      final userProfile = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();

      if (!userProfile.exists) {
        Logger.warning('User profile not found for push notification: $userId');
        return;
      }

      final profileData = userProfile.data();
      final fcmToken = profileData?['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        Logger.warning('No FCM token found for user: $userId');
        return;
      }

      // Send push notification using Firebase Admin SDK (via Cloud Functions)
      // For now, we'll log the notification - in production, this would call a Cloud Function
      Logger.info('Push notification would be sent to user $userId: $title - $message');
      Logger.info('FCM Token: $fcmToken');
      Logger.info('Notification Data: $notificationData');

      // TODO: Implement actual push notification sending via Cloud Functions
      // This would typically be done by calling a Cloud Function that uses Firebase Admin SDK
      // to send the push notification to the user's FCM token

    } catch (e) {
      Logger.error('Error sending push notification: $e');
    }
  }
}