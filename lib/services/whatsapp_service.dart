import 'package:cloud_firestore/cloud_firestore.dart';

class WhatsAppService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send WhatsApp invitation to colleague
  static Future<bool> sendInvitationWhatsApp({
    required String phoneNumber,
    required String colleagueName,
    required String requesterName,
    required String requestId,
  }) async {
    try {
      // Create WhatsApp message
      final message = '''
Hi $colleagueName! 👋

$requesterName has requested verification on TrustCard.

📱 Download: https://trustcard.app/download
🆔 Request ID: $requestId

TrustCard - Professional Networking Made Simple
''';

      // Log WhatsApp request to Firestore for backend processing
      await _firestore.collection('whatsapp_queue').add({
        'phoneNumber': phoneNumber,
        'message': message,
        'type': 'invitation',
        'requestId': requestId,
        'requesterName': requesterName,
        'colleagueName': colleagueName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('WhatsApp invitation queued for $phoneNumber');
      return true;
    } catch (e) {
      print('Error sending WhatsApp invitation: $e');
      return false;
    }
  }

  // Send verification reminder via WhatsApp
  static Future<bool> sendReminderWhatsApp({
    required String phoneNumber,
    required String colleagueName,
    required String requesterName,
  }) async {
    try {
      final message = '''
Hi $colleagueName! 👋

Reminder: $requesterName is waiting for your verification on TrustCard.

📱 Download now: https://trustcard.app/download

TrustCard - Professional Networking Made Simple
''';

      await _firestore.collection('whatsapp_queue').add({
        'phoneNumber': phoneNumber,
        'message': message,
        'type': 'reminder',
        'requesterName': requesterName,
        'colleagueName': colleagueName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('WhatsApp reminder queued for $phoneNumber');
      return true;
    } catch (e) {
      print('Error sending WhatsApp reminder: $e');
      return false;
    }
  }
}

