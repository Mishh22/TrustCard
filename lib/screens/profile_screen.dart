import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../models/user_profile.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthProvider, CardProvider>(
        builder: (context, authProvider, cardProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authProvider.error != null) {
            return _buildErrorWidget(context, authProvider.error!);
          }

          // Get current user ID for ProfileService
          final userId = authProvider.currentUser?.userId ?? authProvider.currentUser?.id;
          if (userId == null) {
            return _buildErrorWidget(context, 'No user logged in');
          }

          // Use ProfileService stream for real-time profile updates
          return StreamBuilder<UserProfile?>(
            stream: ProfileService.getProfileStream(userId),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileSnapshot.hasError) {
                return _buildErrorWidget(context, 'Error loading profile: ${profileSnapshot.error}');
              }

              final profile = profileSnapshot.data;
              return _buildProfileContent(context, authProvider, cardProvider, profile);
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider authProvider, CardProvider cardProvider, UserProfile? profile) {
    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showImagePickerDialog(context, authProvider),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: (profile?.profilePhotoUrl ?? authProvider.currentUser?.profilePhotoUrl) != null
                                  ? NetworkImage(profile?.profilePhotoUrl ?? authProvider.currentUser!.profilePhotoUrl!)
                                  : null,
                              child: (profile?.profilePhotoUrl ?? authProvider.currentUser?.profilePhotoUrl) == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        profile?.fullName ?? authProvider.currentUser?.fullName ?? 'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showEditProfileDialog(context, authProvider),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.currentUser?.companyName ?? 'Company',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.currentUser?.designation ?? 'Designation',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Profile Stats
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Cards',
                      '${cardProvider.cards.length}',
                      Icons.credit_card,
                      AppTheme.primaryBlue,
                    ),
                    _buildStatItem(
                      'Scanned',
                      '${cardProvider.scannedCards.length}',
                      Icons.qr_code_scanner,
                      AppTheme.verifiedGreen,
                    ),
                    _buildStatItem(
                      'Rating',
                      authProvider.currentUser?.customerRating?.toStringAsFixed(1) ?? 'N/A',
                      Icons.star,
                      AppTheme.verifiedYellow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Menu Items
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuSection([
                  _buildMenuItem(
                    context,
                    'My Cards',
                    'View and manage your digital cards',
                    Icons.credit_card,
                    () => context.push('/my-cards'),
                  ),
                  _buildMenuItem(
                    context,
                    'Verification',
                    'Upload documents and upgrade verification level',
                    Icons.verified_user,
                    () => context.push('/verification'),
                  ),
                  // Phone verification is now integrated into card creation flow
       _buildMenuItem(
         context,
         'Settings',
         'App preferences and privacy',
         Icons.settings,
         () => context.push('/settings'),
       ),
       _buildMenuItem(
         context,
         'Scan History',
         'See who scanned your card',
         Icons.history,
         () => context.push('/scan-history'),
       ),
       
                ]),
                
                const SizedBox(height: 24),
                
                Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuSection([
                  _buildMenuItem(
                    context,
                    'Help Center',
                    'Get help and support',
                    Icons.help_outline,
                    () => context.push('/help-center'),
                  ),
                  _buildMenuItem(
                    context,
                    'About',
                    'App version and information',
                    Icons.info_outline,
                    () => context.push('/about'),
                  ),
                ]),
                
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: item,
      )).toList(),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry
                context.read<AuthProvider>().clearError();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TrustCard',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.verified_user,
        size: 48,
        color: AppTheme.primaryBlue,
      ),
      children: [
        const Text('A digital ID verification app for workers and customers.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Digital ID cards'),
        const Text('• QR code scanning'),
        const Text('• Multi-level verification'),
        const Text('• Trust scoring system'),
      ],
    );
  }

  void _showImagePickerDialog(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, authProvider, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, authProvider, ImageSource.gallery);
              },
            ),
            if (authProvider.currentUser?.profilePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto(context, authProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, AuthProvider authProvider, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Upload image to Firebase Storage
          final File imageFile = File(image.path);
          final String userId = authProvider.currentUser?.id ?? 'unknown';
          final String fileName = 'profile-photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final Reference ref = FirebaseStorage.instance.ref().child(fileName);
          
          // Upload the file with metadata
          final UploadTask uploadTask = ref.putFile(
            imageFile,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'uploadedBy': userId,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );
          
          // Wait for upload to complete
          final TaskSnapshot snapshot = await uploadTask;
          
          // Get the download URL
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          
          // Update user profile with Firebase Storage URL
          await authProvider.updateProfile(profilePhotoUrl: downloadUrl);
          
          // Close loading dialog
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: AppTheme.verifiedGreen,
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          _showErrorSnackBar(context, 'Error updating profile photo: ${e.toString()}');
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error picking image: ${e.toString()}');
    }
  }

  Future<void> _removeProfilePhoto(BuildContext context, AuthProvider authProvider) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Update user profile to remove photo
      await authProvider.updateProfile(profilePhotoUrl: '');
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo removed successfully!'),
          backgroundColor: AppTheme.verifiedGreen,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Error removing photo: ${e.toString()}');
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController nameController = TextEditingController(
      text: authProvider.currentUser?.fullName ?? '',
    );
    final TextEditingController companyController = TextEditingController(
      text: authProvider.currentUser?.companyName ?? '',
    );
    final TextEditingController designationController = TextEditingController(
      text: authProvider.currentUser?.designation ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showErrorSnackBar(context, 'Name cannot be empty');
                return;
              }

              // Close the edit dialog first
              Navigator.pop(context);

              try {
                // Get current user ID
                final userId = authProvider.currentUser?.userId ?? authProvider.currentUser?.id;
                if (userId == null) {
                  _showErrorSnackBar(context, 'No user logged in');
                  return;
                }

                // Use ProfileService to update profile
                await ProfileService.updateProfile(userId, {
                  'fullName': nameController.text.trim(),
                  'companyName': companyController.text.trim(),
                  'designation': designationController.text.trim(),
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: AppTheme.verifiedGreen,
                  ),
                );
              } catch (e) {
                _showErrorSnackBar(context, 'Error updating profile: ${e.toString()}');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Notifications: Enabled'),
              Text('• Dark Mode: System Default'),
              Text('• Language: English'),
              SizedBox(height: 16),
              Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Data Collection: Minimal'),
              Text('• Analytics: Anonymous'),
              Text('• Location: Disabled'),
              SizedBox(height: 16),
              Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Auto-sync: Enabled'),
              Text('• Backup: Cloud'),
              Text('• Cache: 15 MB'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Q: How do I create a digital card?'),
              Text('A: Go to Home → Create Card → Fill details → Save'),
              SizedBox(height: 8),
              Text('Q: How does verification work?'),
              Text('A: Upload documents in Profile → Verification'),
              SizedBox(height: 8),
              Text('Q: Can I scan QR codes?'),
              Text('A: Yes, use the Scan tab in bottom navigation'),
              SizedBox(height: 16),
              Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Email: support@trustcard.app'),
              Text('Phone: +1-800-TRUSTCARD'),
              Text('Hours: 9 AM - 6 PM EST'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Help us improve by reporting any issues you encounter.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: issueController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe the issue',
                  hintText: 'Please provide as much detail as possible...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (issueController.text.trim().isEmpty) {
                _showErrorSnackBar(context, 'Please describe the issue');
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reported successfully! We\'ll review it soon.'),
                  backgroundColor: AppTheme.verifiedGreen,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add your phone number to enhance security and enable phone-based features.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.trim().isEmpty) {
                _showErrorSnackBar(context, 'Please enter a phone number');
                return;
              }

              Navigator.pop(context);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Format phone number
                String phoneNumber = phoneController.text.trim();
                if (!phoneNumber.startsWith('+')) {
                  phoneNumber = '+$phoneNumber';
                }

                final success = await authProvider.verifyPhoneForEmailUser(phoneNumber);
                
                Navigator.pop(context); // Close loading dialog

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number verified successfully!'),
                      backgroundColor: AppTheme.verifiedGreen,
                    ),
                  );
                } else {
                  _showErrorSnackBar(context, authProvider.error ?? 'Failed to verify phone number');
                }
              } catch (e) {
                Navigator.pop(context); // Close loading dialog
                _showErrorSnackBar(context, 'Error: ${e.toString()}');
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

}
