import 'package:cloud_firestore/cloud_firestore.dart';

class SMSService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send SMS invitation to colleague
  static Future<bool> sendInvitationSMS({
    required String phoneNumber,
    required String colleagueName,
    required String requesterName,
    required String requestId,
  }) async {
    try {
      // Create SMS message
      final message = '''
Hi $colleagueName! 👋

$requesterName has requested verification on TrustCard.

Download the app: https://trustcard.app/download
Request ID: $requestId

TrustCard - Professional Networking Made Simple
''';

      // Log SMS request to Firestore for backend processing
      await _firestore.collection('sms_queue').add({
        'phoneNumber': phoneNumber,
        'message': message,
        'type': 'invitation',
        'requestId': requestId,
        'requesterName': requesterName,
        'colleagueName': colleagueName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('SMS invitation queued for $phoneNumber');
      return true;
    } catch (e) {
      print('Error sending SMS invitation: $e');
      return false;
    }
  }

  // Send verification reminder SMS
  static Future<bool> sendReminderSMS({
    required String phoneNumber,
    required String colleagueName,
    required String requesterName,
  }) async {
    try {
      final message = '''
Hi $colleagueName! 👋

Reminder: $requesterName is waiting for your verification on TrustCard.

Download now: https://trustcard.app/download

TrustCard - Professional Networking Made Simple
''';

      await _firestore.collection('sms_queue').add({
        'phoneNumber': phoneNumber,
        'message': message,
        'type': 'reminder',
        'requesterName': requesterName,
        'colleagueName': colleagueName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('SMS reminder queued for $phoneNumber');
      return true;
    } catch (e) {
      print('Error sending SMS reminder: $e');
      return false;
    }
  }
}

