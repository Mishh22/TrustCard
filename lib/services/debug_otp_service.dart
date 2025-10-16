import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class DebugOTPService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Debug OTP sending with detailed logging
  static Future<Map<String, dynamic>> debugSendOTP(String phoneNumber) async {
    Map<String, dynamic> result = {
      'success': false,
      'error': null,
      'verificationId': null,
      'logs': <String>[],
    };
    
    try {
      result['logs'].add('🚀 Starting OTP debug for: $phoneNumber');
      result['logs'].add('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      result['logs'].add('🔑 Firebase project: ${_auth.app.options.projectId}');
      
      // Check Firebase configuration
      result['logs'].add('⚙️ Firebase API Key: ${_auth.app.options.apiKey?.substring(0, 10)}...');
      result['logs'].add('📦 App ID: ${_auth.app.options.appId}');
      
      // Try to send OTP
      result['logs'].add('📤 Attempting to send OTP...');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          result['logs'].add('✅ Auto-verification completed');
          result['success'] = true;
        },
        verificationFailed: (FirebaseAuthException e) {
          result['logs'].add('❌ Verification failed: ${e.code} - ${e.message}');
          result['error'] = '${e.code}: ${e.message}';
        },
        codeSent: (String verificationId, int? resendToken) {
          result['logs'].add('✅ OTP sent successfully');
          result['logs'].add('🆔 Verification ID: ${verificationId.substring(0, 20)}...');
          result['verificationId'] = verificationId;
          result['success'] = true;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          result['logs'].add('⏰ Auto-retrieval timeout');
          result['verificationId'] = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      // Wait for callbacks
      await Future.delayed(const Duration(seconds: 3));
      
      if (result['verificationId'] == null && result['error'] == null) {
        result['logs'].add('⚠️ No response from Firebase - possible configuration issue');
        result['error'] = 'No response from Firebase';
      }
      
    } catch (e) {
      result['logs'].add('💥 Exception: $e');
      result['error'] = e.toString();
    }
    
    return result;
  }
  
  /// Get Firebase configuration details
  static Map<String, dynamic> getFirebaseConfig() {
    return {
      'projectId': _auth.app.options.projectId,
      'apiKey': _auth.app.options.apiKey?.substring(0, 10) + '...',
      'appId': _auth.app.options.appId,
      'messagingSenderId': _auth.app.options.messagingSenderId,
      'storageBucket': _auth.app.options.storageBucket,
    };
  }
}
