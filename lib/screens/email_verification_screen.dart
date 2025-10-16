import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.verifiedGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email,
                  size: 64,
                  color: AppTheme.verifiedGreen,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Verify with Company Email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Enter your company email address to get instant verification. '
              'We\'ll send you a verification link to confirm your employment.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Benefits Section
            _buildBenefitItem(
              Icons.flash_on,
              'Instant Verification',
              'Get verified within minutes',
            ),
            
            const SizedBox(height: 16),
            
            _buildBenefitItem(
              Icons.lock,
              'Secure & Private',
              'Your email is encrypted and safe',
            ),
            
            const SizedBox(height: 16),
            
            _buildBenefitItem(
              Icons.check_circle,
              'Free to Use',
              'No charges for email verification',
            ),
            
            const SizedBox(height: 40),
            
            // Email Input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Company Email',
                hintText: 'your.name@company.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Make sure to use your official company email address. '
              'Personal emails (Gmail, Yahoo, etc.) won\'t work.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Send Verification Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verifiedGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send Verification Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.verifiedGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.verifiedGreen, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendVerificationEmail() async {
    final email = _emailController.text.trim();
    
    // Validation
    if (email.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }
    
    if (!email.contains('@')) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    
    // Check if it's a personal email
    final personalDomains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'icloud.com', 'me.com'];
    final domain = email.split('@').last.toLowerCase();
    if (personalDomains.contains(domain)) {
      _showSnackBar('Please use your company email, not a personal email');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        _showSnackBar('Please login first');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Check if email is already verified
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      
      if (updatedUser?.emailVerified == true) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Your email is already verified!');
        return;
      }
      
      // Store the company email in Firestore for verification tracking
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'companyEmail': email,
        'companyEmailDomain': domain,
        'emailVerificationSentAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      }, SetOptions(merge: true));
      
      // Send verification email using Firebase Auth
      await user.sendEmailVerification();
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: AppTheme.verifiedGreen,
            size: 64,
          ),
          title: const Text('Verification Email Sent!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We\'ve sent a verification link to $email.\n\n'
                'Please check your email and click the link to complete your verification.\n\n'
                'After clicking the link, come back and tap "I\'ve Verified" below.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to verification screen
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check verification status
                await _checkVerificationStatus();
              },
              child: const Text('I\'ve Verified'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String message = 'Failed to send verification email.';
      if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please try again later.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }
      
      _showSnackBar(message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('An error occurred. Please try again.');
    }
  }
  
  Future<void> _checkVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Reload user to get latest verification status
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      if (updatedUser?.emailVerified == true) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'emailVerified': true,
          'emailVerifiedAt': FieldValue.serverTimestamp(),
        });
        
        // Update user card verification level
        await FirebaseFirestore.instance
            .collection('userCards')
            .doc(user.uid)
            .set({
          'verificationLevel': 'basic',
          'emailVerified': true,
          'trustScore': 0.3, // Base trust score for email verification
        }, SetOptions(merge: true));
        
        // Show success
        Navigator.of(context).pop(); // Close verification dialog
        Navigator.of(context).pop(); // Go back to verification screen
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email verified successfully! Your trust score has been updated.'),
            backgroundColor: AppTheme.verifiedGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showSnackBar('Email not verified yet. Please click the link in your email first.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading if still showing
        _showSnackBar('Error checking verification status. Please try again.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

