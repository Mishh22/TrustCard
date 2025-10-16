import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employment_event.dart';

class EmploymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track employment event
  static Future<void> trackEmploymentEvent({
    required String userId,
    required String companyId,
    required String designation,
    required String action,
    String? previousDesignation,
    String? previousCompanyId,
    Map<String, dynamic>? metadata,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final employmentEvent = EmploymentEvent(
        id: _firestore.collection('fact_employment_events').doc().id,
        userId: userId,
        companyId: companyId,
        designation: designation,
        action: action,
        occurredAt: DateTime.now(),
        previousDesignation: previousDesignation,
        previousCompanyId: previousCompanyId,
        metadata: metadata,
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );

      await _firestore
          .collection('fact_employment_events')
          .doc(employmentEvent.id)
          .set(employmentEvent.toMap());
    } catch (e) {
      print('Error tracking employment event: $e');
    }
  }

  // Track job change
  static Future<void> trackJobChange({
    required String userId,
    required String newCompanyId,
    required String newDesignation,
    String? oldCompanyId,
    String? oldDesignation,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      // Track leaving old job
      if (oldCompanyId != null) {
        await trackEmploymentEvent(
          userId: userId,
          companyId: oldCompanyId,
          designation: oldDesignation ?? 'Unknown',
          action: 'left',
          tenantId: tenantId,
          effectiveRole: effectiveRole,
        );
      }

      // Track joining new job
      await trackEmploymentEvent(
        userId: userId,
        companyId: newCompanyId,
        designation: newDesignation,
        action: 'joined',
        previousCompanyId: oldCompanyId,
        previousDesignation: oldDesignation,
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );
    } catch (e) {
      print('Error tracking job change: $e');
    }
  }

  // Track role change within same company
  static Future<void> trackRoleChange({
    required String userId,
    required String companyId,
    required String newDesignation,
    required String oldDesignation,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      await trackEmploymentEvent(
        userId: userId,
        companyId: companyId,
        designation: newDesignation,
        action: 'changed_role',
        previousDesignation: oldDesignation,
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );
    } catch (e) {
      print('Error tracking role change: $e');
    }
  }

  // Get employment history for user
  static Future<List<EmploymentEvent>> getEmploymentHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('fact_employment_events')
          .where('userId', isEqualTo: userId)
          .orderBy('occurredAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EmploymentEvent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting employment history: $e');
      return [];
    }
  }

  // Get current employment status
  static Future<EmploymentEvent?> getCurrentEmployment(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('fact_employment_events')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'joined')
          .orderBy('occurredAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return EmploymentEvent.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting current employment: $e');
      return null;
    }
  }
}
