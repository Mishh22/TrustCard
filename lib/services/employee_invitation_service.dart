import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sms_service.dart';
import 'whatsapp_service.dart';
import 'invitation_service.dart';

class EmployeeInvitationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send invitation to employee
  static Future<bool> sendEmployeeInvitation({
    required String employeeId,
    required String employeeName,
    required String employeePhone,
    required String companyName,
    required String adminName,
  }) async {
    try {
      // Create invitation message
      final message = '''
Hi $employeeName! 👋

You've been added to $companyName on TrustCard by $adminName.

📱 Download: https://trustcard.app/download
🆔 Employee ID: $employeeId

Complete your profile to get started.

TrustCard - Professional Networking Made Simple
''';

      // REAL-TIME TESTING: Send actual SMS/WhatsApp
      await _sendRealTimeInvitation(employeePhone, message);

      // Update employee record with actual invitation timestamp
      await _updateEmployeeInvitationStatus(employeeId, DateTime.now());

      // Also log to Firestore for production tracking
      await _logInvitationToFirestore(
        employeeId: employeeId,
        employeeName: employeeName,
        employeePhone: employeePhone,
        companyName: companyName,
        adminName: adminName,
        message: message,
      );

      print('✅ REAL-TIME: Employee invitation sent to $employeePhone');
      return true;
    } catch (e) {
      print('❌ Error sending employee invitation: $e');
      return false;
    }
  }

  // Update employee record with invitation status
  static Future<void> _updateEmployeeInvitationStatus(String employeeId, DateTime invitationTime) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update({
        'invitationSentAt': Timestamp.fromDate(invitationTime),
        'invitationStatus': 'sent',
      });
      print('✅ Updated employee invitation status: $employeeId');
    } catch (e) {
      print('❌ Error updating employee invitation status: $e');
    }
  }

  // Send real-time SMS/WhatsApp invitation
  static Future<void> _sendRealTimeInvitation(String phoneNumber, String message) async {
    try {
      // Clean phone number (remove spaces, add + if needed)
      String cleanPhone = phoneNumber.replaceAll(' ', '').replaceAll('-', '');
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+$cleanPhone';
      }

      print('📱 REAL-TIME TESTING: Opening SMS/WhatsApp for $cleanPhone');
      print('📝 Message: $message');

      // ENHANCED CONSOLE OUTPUT FOR TESTING
      print('\n' + '='*60);
      print('🚀 EMPLOYEE INVITATION TESTING');
      print('='*60);
      print('📞 Phone Number: $cleanPhone');
      print('📱 Message Preview:');
      print('-'*40);
      print(message);
      print('-'*40);
      print('⚠️  NOTE: URL Launcher opens SMS app but requires manual "Send"');
      print('⚠️  For real SMS delivery, backend server with SMS service needed');
      print('='*60 + '\n');

      // Try SMS first
      final smsUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('✅ SMS app opened successfully - Please tap "Send" manually');
      } else {
        print('❌ Could not open SMS app');
      }

      // Also try WhatsApp
      final whatsappUri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(whatsappUri)) {
        // Small delay to let SMS app open first
        await Future.delayed(const Duration(seconds: 1));
        await launchUrl(whatsappUri);
        print('✅ WhatsApp opened successfully - Please tap "Send" manually');
      } else {
        print('❌ Could not open WhatsApp');
      }

    } catch (e) {
      print('❌ Error in real-time invitation: $e');
    }
  }

  // Log invitation to Firestore for production tracking
  static Future<void> _logInvitationToFirestore({
    required String employeeId,
    required String employeeName,
    required String employeePhone,
    required String companyName,
    required String adminName,
    required String message,
  }) async {
    try {
      // Log to Firestore for backend processing (production)
      await _firestore.collection('sms_queue').add({
        'phoneNumber': employeePhone,
        'message': message,
        'type': 'employee_invitation',
        'employeeId': employeeId,
        'employeeName': employeeName,
        'companyName': companyName,
        'adminName': adminName,
        'status': 'sent_realtime',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Track invitation
      await InvitationService.trackInvitationSent(
        colleaguePhone: employeePhone,
        colleagueName: employeeName,
        requesterId: adminName,
        requestId: employeeId,
        channels: ['sms', 'whatsapp'],
      );

      // Log activity
      await _firestore.collection('activityLogs').add({
        'type': 'employee_invitation_sent',
        'title': 'Employee Invitation Sent (Real-time)',
        'details': 'Real-time invitation sent to $employeeName for $companyName',
        'timestamp': FieldValue.serverTimestamp(),
        'data': {
          'employeeId': employeeId,
          'employeeName': employeeName,
          'employeePhone': employeePhone,
          'companyName': companyName,
          'method': 'realtime_testing',
        },
      });

    } catch (e) {
      print('❌ Error logging to Firestore: $e');
    }
  }

  // Validate employee ID when user creates card
  static Future<Map<String, dynamic>?> validateEmployeeId({
    required String enteredEmployeeId,
    required String phoneNumber,
  }) async {
    try {
      // Find employee record by phone number
      final employeeQuery = await _firestore
          .collection('employees')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('isActive', isEqualTo: true)
          .get();

      if (employeeQuery.docs.isEmpty) {
        // Not an employee invitation
        return null;
      }

      final employeeData = employeeQuery.docs.first.data();
      final correctEmployeeId = employeeData['employeeId'];
      final companyId = employeeData['companyId'];
      final createdAt = (employeeData['createdAt'] as Timestamp).toDate();
      final expiresAt = createdAt.add(const Duration(days: 7));

      // Check if invitation expired
      if (DateTime.now().isAfter(expiresAt)) {
        return {
          'status': 'expired',
          'message': 'Employee invitation has expired',
        };
      }

      // Check if employee ID matches
      final isMatch = enteredEmployeeId == correctEmployeeId;

      return {
        'status': isMatch ? 'match' : 'mismatch',
        'correctEmployeeId': correctEmployeeId,
        'enteredEmployeeId': enteredEmployeeId,
        'companyId': companyId,
        'employeeData': employeeData,
        'isMatch': isMatch,
      };
    } catch (e) {
      print('Error validating employee ID: $e');
      return null;
    }
  }

  // Notify company admin about employee card creation
  static Future<void> notifyCompanyAboutEmployeeCard({
    required String companyId,
    required String employeeName,
    required String employeePhone,
    required String enteredEmployeeId,
    required String correctEmployeeId,
    required bool isMatch,
  }) async {
    try {
      final notificationType = isMatch ? 'employee_card_created' : 'employee_id_mismatch';
      final title = isMatch 
          ? 'Employee Card Created' 
          : 'Employee ID Mismatch Alert';
      final message = isMatch
          ? '$employeeName has created their card with correct Employee ID'
          : '$employeeName created card with wrong ID: $enteredEmployeeId (correct: $correctEmployeeId)';

      // Create notification for company admin
      await _firestore.collection('notifications').add({
        'userId': companyId,
        'type': notificationType,
        'title': title,
        'message': message,
        'data': {
          'employeeName': employeeName,
          'employeePhone': employeePhone,
          'enteredEmployeeId': enteredEmployeeId,
          'correctEmployeeId': correctEmployeeId,
          'isMatch': isMatch,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Log activity
      await _firestore.collection('activityLogs').add({
        'userId': companyId,
        'type': notificationType,
        'title': title,
        'details': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': isMatch ? 'success' : 'warning',
        'data': {
          'employeeName': employeeName,
          'employeePhone': employeePhone,
          'enteredEmployeeId': enteredEmployeeId,
          'correctEmployeeId': correctEmployeeId,
          'isMatch': isMatch,
        },
      });

      print('Company notified about employee card creation: $employeeName');
    } catch (e) {
      print('Error notifying company: $e');
    }
  }
}

