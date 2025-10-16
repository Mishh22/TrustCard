import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart' as app_auth;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _inputController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _isPhoneValid = false;
  // Removed _inputType - phone-only authentication
  String? _error;

  @override
  void initState() {
    super.initState();
    // No pre-fill - user enters 10-digit Indian number directly
  }

  @override
  void dispose() {
    _inputController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // App Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                const Text(
                  'TrustCard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Digital ID Verification',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 48),

                // Universal Input Form
                if (!_isOtpSent) _buildUniversalInputForm(),
                if (_isOtpSent) _buildOtpForm(),
                
                // Social Sign-in Options removed - using phone/email only

                const SizedBox(height: 40),

                // Footer
                const Text(
                  'Secure • Verified • Trusted',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildOtpForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Verification Code',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'We sent a 6-digit code to ${_inputController.text}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: '123456',
              prefixIcon: const Icon(Icons.security),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP';
              }
              if (value.length != 6) {
                return 'Please enter a valid 6-digit OTP';
              }
              return null;
            },
          ),
          
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Resend OTP'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (_inputController.text.isEmpty) {
      setState(() {
        _error = 'Please enter your phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use real Firebase phone authentication
      print('Sending OTP via Firebase...');
      
      // Format phone number for Firebase (auto-add +91 for Indian numbers)
      String phoneNumber = _inputController.text.trim();
      
      // Handle test numbers first (don't add +91 for test numbers)
      if (phoneNumber == '8888888888') {
        phoneNumber = '+918888888888'; // Convert test number to proper format
      } else if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Auto-add +91 for other Indian numbers
      }
      
      print('Formatted phone number: $phoneNumber');
      
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final success = await authProvider.sendOTP(phoneNumber);
      
      print('OTP send result: $success');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          // Check if user was auto-verified (for test phone numbers)
          if (authProvider.currentUser != null) {
            // User was auto-verified, navigate to home
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone verified successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/');
            }
          } else {
            // Wait for verification ID to be set before showing OTP input
            // This ensures the OTP verification will work properly
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isOtpSent = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP sent successfully! Check your SMS.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });
          }
        } else {
          setState(() {
            _error = authProvider.error ?? 'Phone authentication requires a real device to receive SMS. Simulators cannot receive SMS messages. Please test on a physical device or use email authentication instead.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      setState(() {
        _error = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use real Firebase OTP verification
      print('Verifying OTP via Firebase...');
      
      // Format phone number for Firebase (auto-add +91 for Indian numbers)
      String phoneNumber = _inputController.text.trim();
      
      // Handle test numbers first (don't add +91 for test numbers)
      if (phoneNumber == '8888888888') {
        phoneNumber = '+918888888888'; // Convert test number to proper format
      } else if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Auto-add +91 for other Indian numbers
      }
      
      // Use AuthProvider's real Firebase OTP verification
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final success = await authProvider.verifyOTP(phoneNumber, _otpController.text);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        } else {
          setState(() {
            _error = authProvider.error ?? 'OTP verification failed';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use real Firebase phone authentication
      print('Resending OTP via Firebase...');
      
      // Format phone number for Firebase (auto-add +91 for Indian numbers)
      String phoneNumber = _inputController.text.trim();
      
      // Handle test numbers first (don't add +91 for test numbers)
      if (phoneNumber == '8888888888') {
        phoneNumber = '+918888888888'; // Convert test number to proper format
      } else if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Auto-add +91 for other Indian numbers
      }
      
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final success = await authProvider.sendOTP(phoneNumber);
      
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _error = authProvider.error ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildUniversalInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSignUp ? 'Create Your Account' : 'Sign In',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _isSignUp 
                ? 'Enter your phone number or email to get started'
                : 'Enter your phone number or email to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _inputController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (value) {
              setState(() {
                _isPhoneValid = value.length == 10 && RegExp(r'^[6-9]').hasMatch(value);
              });
            },
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '9876543210',
              helperText: 'Enter your 10-digit Indian mobile number',
              helperMaxLines: 2,
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              // Phone number validation for Indian numbers (10 digits)
              if (value.length != 10) {
                return 'Indian phone number must be 10 digits';
              }
              // Check if it starts with valid Indian mobile prefixes (6,7,8,9)
              if (!RegExp(r'^[6-9]').hasMatch(value)) {
                return 'Indian mobile number must start with 6, 7, 8, or 9';
              }
              return null;
            },
          ),
          
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Debug button for OTP troubleshooting
          if (_isOtpSent) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                      authProvider.debugOTPSession();
                    },
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Debug OTP'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                      authProvider.clearOTPSession();
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _error = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OTP session cleared. Please request a new OTP.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear & Retry'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoading || !_isPhoneValid) ? null : _handleUniversalAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_getButtonText()),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp ? 'Already have an account? ' : 'Need an account? ',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Sign In' : 'Sign Up',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed _detectInputType and _getInputIcon - phone-only authentication

  String _getButtonText() {
    return 'Send OTP';
  }

  Future<void> _handleUniversalAuth() async {
    if (_inputController.text.isEmpty) {
      setState(() {
        _error = 'Please enter your phone number';
      });
      return;
    }

    // Phone-only authentication - send OTP
    await _sendOtp();
  }


  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }






  Future<void> _handleEmailAuth(String email, String password, bool isSignUp) async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential? result;
      if (isSignUp) {
        result = await FirebaseService.createUserWithEmailAndPassword(email, password);
      } else {
        result = await FirebaseService.signInWithEmailAndPassword(email, password);
      }

      if (result != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Update AuthProvider with successful authentication
          final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
          await authProvider.login(result.user?.email ?? result.user?.phoneNumber ?? '', '');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isSignUp ? 'Account created successfully!' : 'Signed in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home screen
          context.go('/');
        }
      } else {
        setState(() {
          _error = 'Authentication failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

}
