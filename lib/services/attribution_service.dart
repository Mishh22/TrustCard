import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attribution_data.dart';

class AttributionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track user attribution
  static Future<void> trackAttribution({
    required String userId,
    String? source,
    String? medium,
    String? campaign,
    String? adGroup,
    String? channel,
    String? invitedBy,
    String? inviteId,
  }) async {
    try {
      final attributionData = AttributionData(
        id: _firestore.collection('marketing_attribution').doc().id,
        userId: userId,
        source: source,
        medium: medium,
        campaign: campaign,
        adGroup: adGroup,
        channel: channel,
        firstTouchAt: DateTime.now(),
        lastTouchAt: DateTime.now(),
        firstSessionAt: DateTime.now(),
        invitedBy: invitedBy,
        inviteId: inviteId,
      );

      await _firestore
          .collection('marketing_attribution')
          .doc(attributionData.id)
          .set(attributionData.toMap());
    } catch (e) {
      print('Error tracking attribution: $e');
    }
  }

  // Update attribution data
  static Future<void> updateAttribution({
    required String userId,
    String? source,
    String? medium,
    String? campaign,
    String? adGroup,
    String? channel,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('marketing_attribution')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'source': source,
          'medium': medium,
          'campaign': campaign,
          'adGroup': adGroup,
          'channel': channel,
          'lastTouchAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error updating attribution: $e');
    }
  }

  // Get attribution data for user
  static Future<AttributionData?> getAttributionData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('marketing_attribution')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AttributionData.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting attribution data: $e');
      return null;
    }
  }

  // Track campaign conversion
  static Future<void> trackConversion({
    required String userId,
    required String campaign,
    required String conversionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('campaign_conversions').add({
        'userId': userId,
        'campaign': campaign,
        'conversionType': conversionType,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking conversion: $e');
    }
  }

  // Get campaign performance
  static Future<List<Map<String, dynamic>>> getCampaignPerformance({
    String? campaign,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection('campaign_conversions')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (campaign != null) {
        query = query.where('campaign', isEqualTo: campaign);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting campaign performance: $e');
      return [];
    }
  }

  // Track referral
  static Future<void> trackReferral({
    required String referrerId,
    required String referredId,
    required String referralCode,
  }) async {
    try {
      await _firestore.collection('referrals').add({
        'referrerId': referrerId,
        'referredId': referredId,
        'referralCode': referralCode,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking referral: $e');
    }
  }

  // Get referral data
  static Future<List<Map<String, dynamic>>> getReferralData({
    String? referrerId,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection('referrals')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (referrerId != null) {
        query = query.where('referrerId', isEqualTo: referrerId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting referral data: $e');
      return [];
    }
  }
}
