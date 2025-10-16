import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_delivery.dart';

class NotificationDeliveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track notification delivery
  static Future<void> trackDelivery({
    required String notificationId,
    required String userId,
    required String type,
    required String channel,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final delivery = NotificationDelivery(
        id: _firestore.collection('notification_delivery').doc().id,
        notificationId: notificationId,
        userId: userId,
        type: type,
        channel: channel,
        sendAt: DateTime.now(),
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );

      await _firestore
          .collection('notification_delivery')
          .doc(delivery.id)
          .set(delivery.toMap());
    } catch (e) {
      print('Error tracking notification delivery: $e');
    }
  }

  // Update delivery status
  static Future<void> updateDeliveryStatus({
    required String notificationId,
    required String status, // delivered, opened, failed
    String? failureCode,
    String? providerMessageId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('notification_delivery')
          .where('notificationId', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final now = DateTime.now();
        
        Map<String, dynamic> updates = {};
        
        if (status == 'delivered') {
          updates['deliveredAt'] = now.toIso8601String();
        } else if (status == 'opened') {
          updates['openedAt'] = now.toIso8601String();
        } else if (status == 'failed') {
          updates['failureCode'] = failureCode;
          updates['retryCount'] = FieldValue.increment(1);
        }
        
        if (providerMessageId != null) {
          updates['providerMessageId'] = providerMessageId;
        }

        await doc.reference.update(updates);
      }
    } catch (e) {
      print('Error updating delivery status: $e');
    }
  }

  // Get delivery metrics
  static Future<Map<String, dynamic>> getDeliveryMetrics({
    String? userId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('notification_delivery');
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      
      if (startDate != null) {
        query = query.where('sendAt', isGreaterThan: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('sendAt', isLessThan: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final deliveries = querySnapshot.docs
          .map((doc) => NotificationDelivery.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final totalSent = deliveries.length;
      final delivered = deliveries.where((d) => d.deliveredAt != null).length;
      final opened = deliveries.where((d) => d.openedAt != null).length;
      final failed = deliveries.where((d) => d.failureCode != null).length;

      return {
        'totalSent': totalSent,
        'delivered': delivered,
        'opened': opened,
        'failed': failed,
        'deliveryRate': totalSent > 0 ? (delivered / totalSent) * 100 : 0,
        'openRate': delivered > 0 ? (opened / delivered) * 100 : 0,
        'failureRate': totalSent > 0 ? (failed / totalSent) * 100 : 0,
      };
    } catch (e) {
      print('Error getting delivery metrics: $e');
      return {};
    }
  }

  // Get delivery history for user
  static Future<List<NotificationDelivery>> getDeliveryHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notification_delivery')
          .where('userId', isEqualTo: userId)
          .orderBy('sendAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationDelivery.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting delivery history: $e');
      return [];
    }
  }
}
