import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/scan_history_service.dart';
import '../services/session_service.dart';
import '../services/attribution_service.dart';

class AnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track user engagement
  static Future<void> trackEngagement({
    required String userId,
    required String action,
    required String screen,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('engagement_events').add({
        'userId': userId,
        'action': action,
        'screen': screen,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking engagement: $e');
    }
  }

  // Track feature usage
  static Future<void> trackFeatureUsage({
    required String userId,
    required String feature,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('feature_usage').add({
        'userId': userId,
        'feature': feature,
        'action': action,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking feature usage: $e');
    }
  }

  // Get user engagement metrics
  static Future<Map<String, dynamic>> getUserEngagementMetrics(String userId) async {
    try {
      final engagementSnapshot = await _firestore
          .collection('engagement_events')
          .where('userId', isEqualTo: userId)
          .get();

      final featureSnapshot = await _firestore
          .collection('feature_usage')
          .where('userId', isEqualTo: userId)
          .get();

      final sessions = await SessionService.getUserSessions(userId);
      final scanHistory = await ScanHistoryService.getScanHistory(userId);

      // Calculate engagement metrics
      final totalEngagementEvents = engagementSnapshot.docs.length;
      final totalFeatureUsage = featureSnapshot.docs.length;
      final totalSessions = sessions.length;
      final totalScans = scanHistory.length;

      // Calculate session duration
      final totalSessionDuration = sessions
          .where((s) => s.durationSeconds != null)
          .fold(0, (sum, s) => sum + (s.durationSeconds ?? 0));

      // Calculate daily active usage
      final now = DateTime.now();
      final last7Days = now.subtract(Duration(days: 7));
      final recentSessions = sessions.where((s) => s.sessionStart.isAfter(last7Days)).length;

      return {
        'totalEngagementEvents': totalEngagementEvents,
        'totalFeatureUsage': totalFeatureUsage,
        'totalSessions': totalSessions,
        'totalScans': totalScans,
        'totalSessionDuration': totalSessionDuration,
        'averageSessionDuration': totalSessions > 0 ? totalSessionDuration / totalSessions : 0,
        'dailyActiveUsage': recentSessions,
        'engagementScore': _calculateEngagementScore(
          totalEngagementEvents,
          totalFeatureUsage,
          totalSessions,
          totalScans,
        ),
      };
    } catch (e) {
      print('Error getting user engagement metrics: $e');
      return {};
    }
  }

  // Get business intelligence metrics
  static Future<Map<String, dynamic>> getBusinessIntelligenceMetrics() async {
    try {
      // Get user counts
      final usersSnapshot = await _firestore.collection('user_profiles').get();
      final totalUsers = usersSnapshot.docs.length;

      // Get card counts
      final cardsSnapshot = await _firestore.collection('user_cards').get();
      final totalCards = cardsSnapshot.docs.length;

      // Get scan counts
      final scansSnapshot = await _firestore.collection('scan_history').get();
      final totalScans = scansSnapshot.docs.length;

      // Get company counts
      final companiesSnapshot = await _firestore.collection('company_details').get();
      final totalCompanies = companiesSnapshot.docs.length;

      // Get attribution data
      final attributionSnapshot = await _firestore.collection('marketing_attribution').get();
      final totalAttributions = attributionSnapshot.docs.length;

      // Calculate growth metrics
      final now = DateTime.now();
      final last30Days = now.subtract(Duration(days: 30));
      final last7Days = now.subtract(Duration(days: 7));

      final recentUsers = usersSnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['createdAt'] != null &&
                DateTime.parse(data['createdAt']).isAfter(last30Days);
          })
          .length;

      final recentScans = scansSnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['scannedAt'] != null &&
                DateTime.parse(data['scannedAt']).isAfter(last7Days);
          })
          .length;

      return {
        'totalUsers': totalUsers,
        'totalCards': totalCards,
        'totalScans': totalScans,
        'totalCompanies': totalCompanies,
        'totalAttributions': totalAttributions,
        'recentUsers': recentUsers,
        'recentScans': recentScans,
        'userGrowthRate': totalUsers > 0 ? (recentUsers / totalUsers) * 100 : 0,
        'scanGrowthRate': totalScans > 0 ? (recentScans / totalScans) * 100 : 0,
        'cardsPerUser': totalUsers > 0 ? totalCards / totalUsers : 0,
        'scansPerUser': totalUsers > 0 ? totalScans / totalUsers : 0,
      };
    } catch (e) {
      print('Error getting business intelligence metrics: $e');
      return {};
    }
  }

  // Get cohort analysis
  static Future<Map<String, dynamic>> getCohortAnalysis() async {
    try {
      final usersSnapshot = await _firestore.collection('user_profiles').get();
      final sessionsSnapshot = await _firestore.collection('sessions').get();

      // Group users by creation month
      final userCohorts = <String, List<String>>{};
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          final createdAt = DateTime.parse(data['createdAt']);
          final cohort = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
          userCohorts.putIfAbsent(cohort, () => []).add(doc.id);
        }
      }

      // Calculate retention for each cohort
      final cohortRetention = <String, Map<String, dynamic>>{};
      for (final cohort in userCohorts.keys) {
        final cohortUsers = userCohorts[cohort]!;
        final cohortSize = cohortUsers.length;

        // Calculate retention for different periods
        final retention1Day = _calculateRetention(cohortUsers, sessionsSnapshot, 1);
        final retention7Day = _calculateRetention(cohortUsers, sessionsSnapshot, 7);
        final retention30Day = _calculateRetention(cohortUsers, sessionsSnapshot, 30);

        cohortRetention[cohort] = {
          'cohortSize': cohortSize,
          'retention1Day': retention1Day,
          'retention7Day': retention7Day,
          'retention30Day': retention30Day,
        };
      }

      return {
        'cohortRetention': cohortRetention,
        'totalCohorts': userCohorts.length,
      };
    } catch (e) {
      print('Error getting cohort analysis: $e');
      return {};
    }
  }

  // Calculate engagement score
  static double _calculateEngagementScore(
    int engagementEvents,
    int featureUsage,
    int sessions,
    int scans,
  ) {
    // Weighted scoring system
    final engagementWeight = 0.3;
    final featureWeight = 0.2;
    final sessionWeight = 0.3;
    final scanWeight = 0.2;

    final normalizedEngagement = engagementEvents / 100.0; // Normalize to 0-1
    final normalizedFeature = featureUsage / 50.0;
    final normalizedSessions = sessions / 20.0;
    final normalizedScans = scans / 10.0;

    return (normalizedEngagement * engagementWeight +
            normalizedFeature * featureWeight +
            normalizedSessions * sessionWeight +
            normalizedScans * scanWeight) *
        100;
  }

  // Calculate retention for cohort
  static double _calculateRetention(
    List<String> cohortUsers,
    QuerySnapshot sessionsSnapshot,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final activeUsers = <String>{};

    for (final doc in sessionsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != null && cohortUsers.contains(data['userId'])) {
        if (data['sessionStart'] != null) {
          final sessionStart = DateTime.parse(data['sessionStart']);
          if (sessionStart.isAfter(cutoffDate)) {
            activeUsers.add(data['userId']);
          }
        }
      }
    }

    return cohortUsers.isNotEmpty ? activeUsers.length / cohortUsers.length : 0.0;
  }

  // Get feature adoption metrics
  static Future<Map<String, dynamic>> getFeatureAdoptionMetrics() async {
    try {
      final featureSnapshot = await _firestore.collection('feature_usage').get();
      final usersSnapshot = await _firestore.collection('user_profiles').get();

      final totalUsers = usersSnapshot.docs.length;
      final featureUsage = <String, int>{};

      for (final doc in featureSnapshot.docs) {
        final data = doc.data();
        final feature = data['feature'] ?? 'unknown';
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }

      final adoptionRates = <String, double>{};
      for (final feature in featureUsage.keys) {
        adoptionRates[feature] = totalUsers > 0 ? (featureUsage[feature]! / totalUsers) * 100 : 0;
      }

      return {
        'totalUsers': totalUsers,
        'featureUsage': featureUsage,
        'adoptionRates': adoptionRates,
      };
    } catch (e) {
      print('Error getting feature adoption metrics: $e');
      return {};
    }
  }
}
