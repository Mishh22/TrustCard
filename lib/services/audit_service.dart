import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/audit_log.dart';

class AuditService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log admin action
  static Future<void> logAction({
    required String actorUserId,
    required String role,
    required String action,
    required String resourcePath,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String? reasonCode,
    String? outcome,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      final auditLog = AuditLog(
        id: _firestore.collection('admin_audit_logs').doc().id,
        actorUserId: actorUserId,
        role: role,
        action: action,
        resourcePath: resourcePath,
        beforeHash: beforeData != null ? _generateHash(beforeData) : null,
        afterHash: afterData != null ? _generateHash(afterData) : null,
        reasonCode: reasonCode,
        deviceId: androidInfo.id,
        timestamp: DateTime.now(),
        outcome: outcome ?? 'success',
      );

      await _firestore
          .collection('admin_audit_logs')
          .doc(auditLog.id)
          .set(auditLog.toMap());
    } catch (e) {
      print('Error logging audit action: $e');
    }
  }

  // Log data access
  static Future<void> logDataAccess({
    required String actorUserId,
    required String resourcePath,
    required String action,
    Map<String, dynamic>? data,
  }) async {
    await logAction(
      actorUserId: actorUserId,
      role: 'user',
      action: action,
      resourcePath: resourcePath,
      beforeData: data,
      outcome: 'success',
    );
  }

  // Log data modification
  static Future<void> logDataModification({
    required String actorUserId,
    required String resourcePath,
    required String action,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String? reasonCode,
  }) async {
    await logAction(
      actorUserId: actorUserId,
      role: 'user',
      action: action,
      resourcePath: resourcePath,
      beforeData: beforeData,
      afterData: afterData,
      reasonCode: reasonCode,
      outcome: 'success',
    );
  }

  // Get audit logs for specific user
  static Future<List<AuditLog>> getAuditLogs(String actorUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection('admin_audit_logs')
          .where('actorUserId', isEqualTo: actorUserId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting audit logs: $e');
      return [];
    }
  }

  // Get audit logs stream for real-time updates
  static Stream<List<AuditLog>> getAuditLogsStream(String actorUserId) {
    return _firestore
        .collection('admin_audit_logs')
        .where('actorUserId', isEqualTo: actorUserId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Generate hash for data integrity
  static String _generateHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
