import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track invitation sent
  static Future<void> trackInvitationSent({
    required String colleaguePhone,
    required String colleagueName,
    required String requesterId,
    required String requestId,
    List<String> channels = const ['app'],
  }) async {
    try {
      await _firestore.collection('invitations').add({
        'colleaguePhone': colleaguePhone,
        'colleagueName': colleagueName,
        'requesterId': requesterId,
        'requestId': requestId,
        'status': 'sent',
        'sentAt': FieldValue.serverTimestamp(),
        'channels': channels, // Track which channels were used (sms, whatsapp, app)
      });
    } catch (e) {
      print('Error tracking invitation sent: $e');
    }
  }

  // Track invitation accepted
  static Future<void> trackInvitationAccepted(String colleaguePhone) async {
    try {
      final snapshot = await _firestore
          .collection('invitations')
          .where('colleaguePhone', isEqualTo: colleaguePhone)
          .where('status', isEqualTo: 'sent')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error tracking invitation accepted: $e');
    }
  }

  // Get invitation context for new user
  static Future<Map<String, dynamic>?> getInvitationContext(String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection('invitations')
          .where('colleaguePhone', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'sent')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting invitation context: $e');
      return null;
    }
  }

  // Get all invitations sent by a user
  static Future<List<Map<String, dynamic>>> getInvitationsSentByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('invitations')
          .where('requesterId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting invitations sent by user: $e');
      return [];
    }
  }

  // Get pending invitations
  static Future<List<Map<String, dynamic>>> getPendingInvitations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('invitations')
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: 'sent')
          .orderBy('sentAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting pending invitations: $e');
      return [];
    }
  }

  // Cancel invitation
  static Future<void> cancelInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling invitation: $e');
    }
  }

  // Resend invitation
  static Future<void> resendInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': 'resent',
        'resentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error resending invitation: $e');
    }
  }
}

