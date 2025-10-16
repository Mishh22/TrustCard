import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing card blocking functionality
class BlockCardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Block a card for a user
  static Future<bool> blockCard({
    required String blockerId,
    required String blockedCardId,
    required String blockedCardOwnerId,
    String? reason,
  }) async {
    try {
      final blockId = _firestore.collection('blocked_cards').doc().id;
      await _firestore.collection('blocked_cards').doc(blockId).set({
        'id': blockId,
        'blockerId': blockerId,
        'blockedCardId': blockedCardId,
        'blockedCardOwnerId': blockedCardOwnerId,
        'blockedAt': FieldValue.serverTimestamp(),
        'reason': reason,
        'isActive': true,
      });
      print('Card blocked successfully: $blockId');
      return true;
    } catch (e) {
      print('Error blocking card: $e');
      return false;
    }
  }

  /// Unblock a card for a user
  static Future<bool> unblockCard({
    required String blockerId,
    required String blockedCardId,
  }) async {
    try {
      final query = await _firestore
          .collection('blocked_cards')
          .where('blockerId', isEqualTo: blockerId)
          .where('blockedCardId', isEqualTo: blockedCardId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({'isActive': false});
      }
      print('Card unblocked successfully');
      return true;
    } catch (e) {
      print('Error unblocking card: $e');
      return false;
    }
  }

  /// Check if a card is blocked by a user
  static Future<bool> isCardBlocked({
    required String blockerId,
    required String blockedCardId,
  }) async {
    try {
      final query = await _firestore
          .collection('blocked_cards')
          .where('blockerId', isEqualTo: blockerId)
          .where('blockedCardId', isEqualTo: blockedCardId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking block status: $e');
      return false;
    }
  }

  /// Get all blocked cards for a user
  static Future<List<Map<String, dynamic>>> getBlockedCards(String blockerId) async {
    try {
      final query = await _firestore
          .collection('blocked_cards')
          .where('blockerId', isEqualTo: blockerId)
          .where('isActive', isEqualTo: true)
          .orderBy('blockedAt', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting blocked cards: $e');
      return [];
    }
  }
}
