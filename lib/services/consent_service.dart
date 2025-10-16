import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/consent_record.dart';

class ConsentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Grant consent for specific scopes
  static Future<void> grantConsent({
    required String userId,
    required List<String> scopes,
    required String policyVersion,
    required String jurisdiction,
    required String method,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      final consentRecord = ConsentRecord(
        id: _firestore.collection('consent_records').doc().id,
        userId: userId,
        scopes: scopes,
        policyVersion: policyVersion,
        jurisdiction: jurisdiction,
        grantedAt: DateTime.now(),
        method: method,
        deviceId: androidInfo.id,
        isActive: true,
      );

      await _firestore
          .collection('consent_records')
          .doc(consentRecord.id)
          .set(consentRecord.toMap());
    } catch (e) {
      print('Error granting consent: $e');
    }
  }

  // Revoke consent for specific scopes
  static Future<void> revokeConsent({
    required String userId,
    required List<String> scopes,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('consent_records')
          .where('userId', isEqualTo: userId)
          .where('scopes', arrayContainsAny: scopes)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'revokedAt': DateTime.now().toIso8601String(),
          'isActive': false,
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error revoking consent: $e');
    }
  }

  // Check if user has consent for specific scope
  static Future<bool> hasConsent({
    required String userId,
    required String scope,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('consent_records')
          .where('userId', isEqualTo: userId)
          .where('scopes', arrayContains: scope)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking consent: $e');
      return false;
    }
  }

  // Get all active consents for user
  static Future<List<ConsentRecord>> getUserConsents(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('consent_records')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('grantedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ConsentRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user consents: $e');
      return [];
    }
  }

  // Get consent stream for real-time updates
  static Stream<List<ConsentRecord>> getUserConsentsStream(String userId) {
    return _firestore
        .collection('consent_records')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('grantedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsentRecord.fromMap(doc.data(), doc.id))
            .toList());
  }
}
