import 'package:flutter/material.dart';
import '../services/debug_auth_service.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({Key? key}) : super(key: key);

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _debugResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Authentication'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onPressed: _isLoading ? null : _debugAuth,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Debug Authentication'),
            ),
            const SizedBox(height: 16),
            if (_debugResult != null) ...[
              const Text(
                'Debug Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _debugResult!['success'] == true
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    border: Border.all(
                      color: _debugResult!['success'] == true
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
                          'Status: ${_debugResult!['success'] == true ? "SUCCESS" : "FAILED"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _debugResult!['success'] == true
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                        if (_debugResult!['error'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${_debugResult!['error']}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Debug Logs:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...(_debugResult!['logs'] as List<String>).map(
                          (log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                        if (_debugResult!['userCredential'] != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'User Credential:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_debugResult!['userCredential'].toString()),
                        ],
                        if (_debugResult!['firebaseUser'] != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Firebase User:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_debugResult!['firebaseUser'].toString()),
                        ],
                        if (_debugResult!['userData'] != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'User Data:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_debugResult!['userData'].toString()),
                        ],
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

  Future<void> _debugAuth() async {
    if (_phoneController.text.isEmpty || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number and OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _debugResult = null;
    });

    try {
      final result = await DebugAuthService.debugAuthFlow(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );

      setState(() {
        _debugResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugResult = {
          'success': false,
          'error': e.toString(),
          'logs': ['Exception: $e'],
        };
        _isLoading = false;
      });
    }
  }
}
