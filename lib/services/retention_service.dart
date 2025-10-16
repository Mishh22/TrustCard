import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/retention_policy.dart';

class RetentionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create retention policy for collection
  static Future<void> createRetentionPolicy({
    required String collection,
    required String piiLevel,
    required int ttlDays,
    String? archivalBucket,
    required String eraseStrategy,
  }) async {
    try {
      final policy = RetentionPolicy(
        id: _firestore.collection('retention_policies').doc().id,
        collection: collection,
        piiLevel: piiLevel,
        ttlDays: ttlDays,
        archivalBucket: archivalBucket,
        eraseStrategy: eraseStrategy,
        lastEvaluatedAt: DateTime.now(),
      );

      await _firestore
          .collection('retention_policies')
          .doc(policy.id)
          .set(policy.toMap());
    } catch (e) {
      print('Error creating retention policy: $e');
    }
  }

  // Get retention policy for collection
  static Future<RetentionPolicy?> getRetentionPolicy(String collection) async {
    try {
      final querySnapshot = await _firestore
          .collection('retention_policies')
          .where('collection', isEqualTo: collection)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return RetentionPolicy.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting retention policy: $e');
      return null;
    }
  }

  // Check if data should be archived
  static Future<bool> shouldArchive(String collection, DateTime createdAt) async {
    try {
      final policy = await getRetentionPolicy(collection);
      if (policy == null) return false;

      final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
      return daysSinceCreation >= policy.ttlDays;
    } catch (e) {
      print('Error checking archive status: $e');
      return false;
    }
  }

  // Archive old data
  static Future<void> archiveOldData(String collection) async {
    try {
      final policy = await getRetentionPolicy(collection);
      if (policy == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: policy.ttlDays));
      
      final querySnapshot = await _firestore
          .collection(collection)
          .where('createdAt', isLessThan: cutoffDate.toIso8601String())
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        if (policy.eraseStrategy == 'tombstone') {
          batch.update(doc.reference, {
            'archivedAt': DateTime.now().toIso8601String(),
            'isArchived': true,
          });
        } else {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      print('Error archiving old data: $e');
    }
  }

  // Get all retention policies
  static Future<List<RetentionPolicy>> getAllRetentionPolicies() async {
    try {
      final querySnapshot = await _firestore
          .collection('retention_policies')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RetentionPolicy.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting retention policies: $e');
      return [];
    }
  }

  // Update retention policy
  static Future<void> updateRetentionPolicy({
    required String policyId,
    int? ttlDays,
    String? eraseStrategy,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (ttlDays != null) updateData['ttlDays'] = ttlDays;
      if (eraseStrategy != null) updateData['eraseStrategy'] = eraseStrategy;
      updateData['lastEvaluatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('retention_policies')
          .doc(policyId)
          .update(updateData);
    } catch (e) {
      print('Error updating retention policy: $e');
    }
  }
}
