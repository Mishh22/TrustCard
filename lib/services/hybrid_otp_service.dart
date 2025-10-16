import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'custom_sms_service.dart';

class HybridOTPService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;
  static String? _generatedOTP;
  static String? _phoneNumber;
  
  /// Send OTP using hybrid approach (Firebase first, then custom SMS)
  static Future<bool> sendOTP(String phoneNumber) async {
    _phoneNumber = phoneNumber;
    
    try {
      // Try Firebase first
      print('🔄 Trying Firebase Phone Authentication...');
      bool firebaseSuccess = await _tryFirebaseOTP(phoneNumber);
      
      if (firebaseSuccess) {
        print('✅ Firebase OTP sent successfully');
        return true;
      }
      
      // If Firebase fails, try custom SMS
      print('🔄 Firebase failed, trying custom SMS...');
      bool customSuccess = await _tryCustomSMS(phoneNumber);
      
      if (customSuccess) {
        print('✅ Custom SMS sent successfully');
        return true;
      }
      
      print('❌ Both Firebase and custom SMS failed');
      return false;
      
    } catch (e) {
      print('❌ Error in hybrid OTP service: $e');
      return false;
    }
  }
  
  /// Try Firebase Phone Authentication
  static Future<bool> _tryFirebaseOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('✅ Firebase auto-verification completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Firebase verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print('✅ Firebase OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print('⏰ Firebase auto-retrieval timeout');
        },
        timeout: const Duration(seconds: 60),
      );
      
      // Wait a bit for the callback
      await Future.delayed(const Duration(seconds: 2));
      return _verificationId != null;
      
    } catch (e) {
      print('❌ Firebase error: $e');
      return false;
    }
  }
  
  /// Try custom SMS service
  static Future<bool> _tryCustomSMS(String phoneNumber) async {
    try {
      // Generate a 6-digit OTP
      _generatedOTP = _generateOTP();
      
      // Send via custom SMS service
      bool success = await CustomSMSService.sendOTPWithMessage(
        phoneNumber: phoneNumber,
        otp: _generatedOTP!,
      );
      
      if (success) {
        print('✅ Custom SMS OTP sent: $_generatedOTP');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Custom SMS error: $e');
      return false;
    }
  }
  
  /// Verify OTP using hybrid approach
  static Future<bool> verifyOTP(String otp) async {
    if (_phoneNumber == null) {
      print('❌ No phone number set for verification');
      return false;
    }
    
    try {
      // If we have a Firebase verification ID, try Firebase first
      if (_verificationId != null) {
        print('🔄 Trying Firebase OTP verification...');
        bool firebaseSuccess = await _verifyFirebaseOTP(otp);
        if (firebaseSuccess) {
          print('✅ Firebase OTP verified successfully');
          return true;
        }
      }
      
      // If Firebase fails or we used custom SMS, verify against generated OTP
      if (_generatedOTP != null) {
        print('🔄 Trying custom OTP verification...');
        bool customSuccess = await _verifyCustomOTP(otp);
        if (customSuccess) {
          print('✅ Custom OTP verified successfully');
          return true;
        }
      }
      
      print('❌ OTP verification failed');
      return false;
      
    } catch (e) {
      print('❌ Error in OTP verification: $e');
      return false;
    }
  }
  
  /// Verify Firebase OTP
  static Future<bool> _verifyFirebaseOTP(String otp) async {
    try {
      if (_verificationId == null) return false;
      
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print('❌ Firebase OTP verification failed: $e');
      return false;
    }
  }
  
  /// Verify custom OTP
  static Future<bool> _verifyCustomOTP(String otp) async {
    if (_generatedOTP == null) return false;
    
    bool isValid = otp == _generatedOTP;
    if (isValid) {
      // Create a mock user session for custom OTP
      print('✅ Custom OTP verified, creating user session');
      // You can implement user session creation here
    }
    
    return isValid;
  }
  
  /// Generate a 6-digit OTP
  static String _generateOTP() {
    Random random = Random();
    int otp = 100000 + random.nextInt(900000); // 6-digit number
    return otp.toString();
  }
  
  /// Clear verification data
  static void clearVerificationData() {
    _verificationId = null;
    _generatedOTP = null;
    _phoneNumber = null;
  }
}
