import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomSMSService {
  // Using a free SMS service for testing
  // In production, use Twilio, AWS SNS, or similar
  static const String _apiKey = 'YOUR_SMS_API_KEY'; // Replace with actual API key
  static const String _senderId = 'TRSTCRD'; // Your sender ID
  
  /// Send OTP via custom SMS service
  static Future<bool> sendOTP({
    required String phoneNumber,
    required String otp,
    required String message,
  }) async {
    try {
      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (!cleanPhone.startsWith('91')) {
        cleanPhone = '91$cleanPhone'; // Add India country code
      }
      
      print('📱 Sending SMS to: $cleanPhone');
      print('📝 Message: $message');
      
      // Example using a free SMS API (replace with your preferred service)
      final response = await http.post(
        Uri.parse('https://api.smsprovider.com/send'), // Replace with actual API
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'to': cleanPhone,
          'message': message,
          'sender_id': _senderId,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ SMS sent successfully');
        return true;
      } else {
        print('❌ SMS failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ SMS error: $e');
      return false;
    }
  }
  
  /// Generate OTP message
  static String generateOTPMessage(String otp) {
    return 'Your TrustCard verification code is: $otp. Valid for 5 minutes. Do not share this code.';
  }
  
  /// Send OTP with custom message
  static Future<bool> sendOTPWithMessage({
    required String phoneNumber,
    required String otp,
  }) async {
    final message = generateOTPMessage(otp);
    return await sendOTP(
      phoneNumber: phoneNumber,
      otp: otp,
      message: message,
    );
  }
}
