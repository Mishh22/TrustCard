import 'package:firebase_auth/firebase_auth.dart';

class SimpleOTPTest {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Simple OTP test that bypasses complex user creation
  static Future<Map<String, dynamic>> testOTPVerification(String phoneNumber, String otp) async {
    Map<String, dynamic> result = {
      'success': false,
      'error': null,
      'userId': null,
      'logs': <String>[],
    };
    
    try {
      result['logs'].add('🚀 Starting simple OTP test');
      result['logs'].add('📱 Phone: $phoneNumber');
      result['logs'].add('🔑 OTP: $otp');
      
      // Check current user
      final currentUser = _auth.currentUser;
      result['logs'].add('👤 Current user: ${currentUser?.uid ?? "null"}');
      
      // Sign out if already signed in
      if (currentUser != null) {
        await _auth.signOut();
        result['logs'].add('✅ Signed out existing user');
      }
      
      // Try to verify phone number and get verification ID
      result['logs'].add('📤 Requesting phone verification...');
      
      String? verificationId;
      bool verificationStarted = false;
      
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
        codeSent: (String vid, int? resendToken) {
          result['logs'].add('✅ OTP sent successfully');
          result['logs'].add('🆔 Verification ID: ${vid.substring(0, 20)}...');
          verificationId = vid;
          verificationStarted = true;
        },
        codeAutoRetrievalTimeout: (String vid) {
          result['logs'].add('⏰ Auto-retrieval timeout');
          verificationId = vid;
        },
        timeout: const Duration(seconds: 60),
      );
      
      // Wait for verification to start
      await Future.delayed(const Duration(seconds: 2));
      
      if (!verificationStarted) {
        result['logs'].add('❌ Phone verification did not start');
        result['error'] = 'Phone verification failed to start';
        return result;
      }
      
      if (verificationId == null) {
        result['logs'].add('❌ No verification ID received');
        result['error'] = 'No verification ID received';
        return result;
      }
      
      // Now try to verify the OTP
      result['logs'].add('🔍 Verifying OTP...');
      
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: otp,
        );
        
        result['logs'].add('🔑 Credential created successfully');
        
        final userCredential = await _auth.signInWithCredential(credential);
        result['logs'].add('✅ User credential sign-in successful');
        
        final user = userCredential.user;
        if (user != null) {
          result['userId'] = user.uid;
          result['success'] = true;
          result['logs'].add('🎉 Authentication successful!');
          result['logs'].add('👤 User ID: ${user.uid}');
          result['logs'].add('📱 Phone: ${user.phoneNumber}');
        } else {
          result['logs'].add('❌ User is null after successful credential verification');
          result['error'] = 'User is null after successful credential verification';
        }
        
      } catch (e) {
        result['logs'].add('❌ Error in credential verification: $e');
        result['error'] = e.toString();
      }
      
    } catch (e) {
      result['logs'].add('💥 Exception in test: $e');
      result['error'] = e.toString();
    }
    
    return result;
  }
}
