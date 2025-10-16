import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/verification_request.dart';
import 'sms_service.dart';
import 'whatsapp_service.dart';
import 'invitation_service.dart';

class VerificationRequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send verification request to a colleague
  static Future<bool> sendVerificationRequest({
    required String colleaguePhone,
    required String colleagueName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if colleague already has an account
      final colleagueQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: colleaguePhone)
          .limit(1)
          .get();

      final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
      final request = VerificationRequest(
        id: requestId,
        requesterId: currentUser.uid,
        requesterName: currentUser.displayName ?? 'Unknown User',
        colleaguePhone: colleaguePhone,
        colleagueName: colleagueName,
        status: VerificationRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      if (colleagueQuery.docs.isNotEmpty) {
        // Colleague has app - send in-app notification
        final colleagueId = colleagueQuery.docs.first.id;
        
        // Save verification request
        await _firestore
            .collection('verification_requests')
            .doc(requestId)
            .set(request.toMap());

        // Create notification for colleague
        await _firestore
            .collection('notifications')
            .add({
          'userId': colleagueId,
          'type': 'verification_request',
          'title': 'Verification Request',
          'message': '${request.requesterName} has requested verification from you',
          'data': {
            'requestId': requestId,
            'requesterId': currentUser.uid,
            'requesterName': request.requesterName,
          },
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        return true;
      } else {
        // Colleague doesn't have app - send SMS/WhatsApp invitation
        await _firestore
            .collection('verification_requests')
            .doc(requestId)
            .set(request.toMap());

        // Send SMS invitation
        await SMSService.sendInvitationSMS(
          phoneNumber: colleaguePhone,
          colleagueName: colleagueName,
          requesterName: request.requesterName,
          requestId: requestId,
        );

        // Send WhatsApp invitation
        await WhatsAppService.sendInvitationWhatsApp(
          phoneNumber: colleaguePhone,
          colleagueName: colleagueName,
          requesterName: request.requesterName,
          requestId: requestId,
        );

        // Track invitation
        await InvitationService.trackInvitationSent(
          colleaguePhone: colleaguePhone,
          colleagueName: colleagueName,
          requesterId: currentUser.uid,
          requestId: requestId,
          channels: ['sms', 'whatsapp'],
        );

        return true;
      }
    } catch (e) {
      print('Error sending verification request: $e');
      return false;
    }
  }

  // Get pending verification requests for current user
  static Stream<List<VerificationRequest>> getPendingRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('verification_requests')
        .where('colleaguePhone', isEqualTo: currentUser.phoneNumber)
        .where('status', isEqualTo: VerificationRequestStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Respond to verification request
  static Future<bool> respondToRequest({
    required String requestId,
    required bool accepted,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Update request status
      await _firestore
          .collection('verification_requests')
          .doc(requestId)
          .update({
        'status': accepted 
            ? VerificationRequestStatus.accepted.name 
            : VerificationRequestStatus.declined.name,
        'respondedAt': FieldValue.serverTimestamp(),
        'response': accepted ? 'accepted' : 'declined',
      });

      // Get request details
      final requestDoc = await _firestore
          .collection('verification_requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        final requesterId = requestData['requesterId'];

        // Notify requester of response
        await _firestore
            .collection('notifications')
            .add({
          'userId': requesterId,
          'type': 'verification_response',
          'title': 'Verification Response',
          'message': accepted 
              ? 'Your verification request was accepted!'
              : 'Your verification request was declined.',
          'data': {
            'requestId': requestId,
            'accepted': accepted,
          },
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      return true;
    } catch (e) {
      print('Error responding to request: $e');
      return false;
    }
  }

  // Get sent verification requests
  static Stream<List<VerificationRequest>> getSentRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('verification_requests')
        .where('requesterId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
