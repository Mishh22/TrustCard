import 'package:flutter/material.dart';
import '../services/simple_otp_test.dart';

class SimpleOTPTestScreen extends StatefulWidget {
  const SimpleOTPTestScreen({Key? key}) : super(key: key);

  @override
  State<SimpleOTPTestScreen> createState() => _SimpleOTPTestScreenState();
}

class _SimpleOTPTestScreenState extends State<SimpleOTPTestScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _testResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple OTP Test'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Simple OTP Test (Bypasses User Creation)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91XXXXXXXXXX',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP',
                hintText: '6-digit code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test OTP (Simple)'),
            ),
            const SizedBox(height: 16),
            if (_testResult != null) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testResult!['success'] == true
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    border: Border.all(
                      color: _testResult!['success'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${_testResult!['success'] == true ? "SUCCESS" : "FAILED"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _testResult!['success'] == true
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                        if (_testResult!['userId'] != null) ...[
                          const SizedBox(height: 8),
                          Text('User ID: ${_testResult!['userId']}'),
                        ],
                        if (_testResult!['error'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${_testResult!['error']}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Debug Logs:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...(_testResult!['logs'] as List<String>).map(
                          (log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testOTP() async {
    if (_phoneController.text.isEmpty || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number and OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final result = await SimpleOTPTest.testOTPVerification(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );

      setState(() {
        _testResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = {
          'success': false,
          'error': e.toString(),
          'logs': ['Exception: $e'],
        };
        _isLoading = false;
      });
    }
  }
}
