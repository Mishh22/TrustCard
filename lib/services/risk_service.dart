import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/risk_signal.dart';

class RiskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log risk signal
  static Future<void> logRiskSignal({
    String? userId,
    String? cardId,
    required String type,
    required double signalScore,
    required Map<String, dynamic> details,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final riskSignal = RiskSignal(
        id: _firestore.collection('risk_signals').doc().id,
        userId: userId,
        cardId: cardId,
        type: type,
        signalScore: signalScore,
        details: details,
        triggeredAt: DateTime.now(),
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );

      await _firestore
          .collection('risk_signals')
          .doc(riskSignal.id)
          .set(riskSignal.toMap());
    } catch (e) {
      print('Error logging risk signal: $e');
    }
  }

  // Log risk outcome
  static Future<void> logRiskOutcome({
    required String caseId,
    required String disposition,
    String? reviewerId,
    required List<String> reasons,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final riskOutcome = RiskOutcome(
        id: _firestore.collection('risk_outcomes').doc().id,
        caseId: caseId,
        disposition: disposition,
        reviewerId: reviewerId,
        decidedAt: DateTime.now(),
        reasons: reasons,
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );

      await _firestore
          .collection('risk_outcomes')
          .doc(riskOutcome.id)
          .set(riskOutcome.toMap());
    } catch (e) {
      print('Error logging risk outcome: $e');
    }
  }

  // Detect rapid scans (potential abuse)
  static Future<void> detectRapidScans(String userId, String cardId) async {
    try {
      final now = DateTime.now();
      final lastHour = now.subtract(Duration(hours: 1));
      
      final recentScans = await _firestore
          .collection('scan_history')
          .where('scannerId', isEqualTo: userId)
          .where('scannedAt', isGreaterThan: Timestamp.fromDate(lastHour))
          .get();

      if (recentScans.docs.length > 20) { // More than 20 scans in 1 hour
        await logRiskSignal(
          userId: userId,
          cardId: cardId,
          type: 'rapid_scans',
          signalScore: 0.8,
          details: {
            'scanCount': recentScans.docs.length,
            'timeWindow': '1_hour',
            'threshold': 20,
          },
        );
      }
    } catch (e) {
      print('Error detecting rapid scans: $e');
    }
  }

  // Detect device churn (potential account takeover)
  static Future<void> detectDeviceChurn(String userId) async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(Duration(hours: 24));
      
      final recentSessions = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .where('sessionStart', isGreaterThan: Timestamp.fromDate(last24Hours))
          .get();

      final deviceIds = recentSessions.docs
          .map((doc) => doc.data()['deviceId'] as String?)
          .where((id) => id != null)
          .toSet();

      if (deviceIds.length > 5) { // More than 5 different devices in 24 hours
        await logRiskSignal(
          userId: userId,
          type: 'device_churn',
          signalScore: 0.7,
          details: {
            'deviceCount': deviceIds.length,
            'timeWindow': '24_hours',
            'threshold': 5,
          },
        );
      }
    } catch (e) {
      print('Error detecting device churn: $e');
    }
  }

  // Get risk signals for user
  static Future<List<RiskSignal>> getRiskSignals(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('risk_signals')
          .where('userId', isEqualTo: userId)
          .orderBy('triggeredAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => RiskSignal.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting risk signals: $e');
      return [];
    }
  }
}
