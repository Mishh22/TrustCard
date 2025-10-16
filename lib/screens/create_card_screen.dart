import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../services/employee_invitation_service.dart';
import '../services/firebase_service.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _designationController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedProfileImage;
  bool _isLoading = false;
  bool _isEmailVerified = false;
  // Removed phone verification - phone is verified at login

  @override
  void initState() {
    super.initState();
    // Auto-populate phone number and name from authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<app_auth.AuthProvider>();
      if (authProvider.currentUser != null) {
        // Auto-populate name with user's official name
        _nameController.text = authProvider.currentUser!.fullName;
        
        // Auto-populate phone number (remove +91 prefix if present for display)
        if (authProvider.currentUser!.phoneNumber != null) {
          String phone = authProvider.currentUser!.phoneNumber!;
          if (phone.startsWith('+91')) {
            phone = phone.substring(3);
          }
          _phoneController.text = phone;
        }
      }
    });
  }

  // Check if user is new (has default "User" name)
  bool get _isNewUser {
    final authProvider = context.read<app_auth.AuthProvider>();
    return authProvider.currentUser?.fullName == 'User';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _companyIdController.dispose();
    _companyPhoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Digital Card'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCard,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              _buildProfilePhotoSection(),
              
              const SizedBox(height: 24),
              
              // Personal Information
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                readOnly: !_isNewUser,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: _isNewUser ? 'Enter your full name' : 'Enter your full name',
                  helperText: _isNewUser 
                      ? 'Enter your real name - this will be your verified identity for all cards'
                      : 'Your verified identity (cannot be changed)',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _isNewUser 
                      ? const Icon(Icons.edit, color: Colors.blue)
                      : const Icon(Icons.verified, color: Colors.green),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  
                  // For new users, allow any name (but not "User")
                  if (_isNewUser) {
                    if (value.trim().toLowerCase() == 'user') {
                      return 'Please enter your real name, not "User"';
                    }
                    return null;
                  }
                  
                  // For existing users, check if name matches user's official name
                  final authProvider = context.read<app_auth.AuthProvider>();
                  if (authProvider.currentUser != null) {
                    final officialName = authProvider.currentUser!.fullName;
                    if (value.trim().toLowerCase() != officialName.toLowerCase()) {
                      return 'Name must match your verified identity: "$officialName"\n\nPlease check the name correctly as no changes may be permitted later.';
                    }
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
                      TextFormField(
                        controller: _phoneController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '9876543210',
                          helperText: 'Phone number from your account (verified)',
                          helperMaxLines: 2,
                          prefixIcon: Icon(Icons.phone),
                          suffixIcon: Icon(Icons.verified, color: Colors.green),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Phone number validation for Indian numbers (10 digits)
                          if (value.length < 10) {
                            return 'Please enter complete 10-digit phone number';
                          }
                          if (value.length > 10) {
                            return 'Phone number cannot exceed 10 digits';
                          }
                          // Check if it starts with valid Indian mobile prefixes (6,7,8,9)
                          if (!RegExp(r'^[6-9]').hasMatch(value)) {
                            return 'Indian mobile number must start with 6, 7, 8, or 9';
                          }
                          return null;
                        },
                        // Phone is read-only and pre-verified at login
                      ),
              
              // Removed phone verification section - phone is verified at login
              
              const SizedBox(height: 16),
              
              // Official Email Field (Optional)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Official Email (Optional)',
                  hintText: 'your.email@company.com',
                  helperText: _isEmailVerified 
                      ? 'Email verified successfully!'
                      : 'Enter your official email for verification',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: _isEmailVerified 
                      ? const Icon(Icons.verified, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _emailController.text.isNotEmpty ? _sendEmailVerification : null,
                        ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Email format validation
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    if (!_isEmailVerified) {
                      return 'Please verify your email address';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isEmailVerified = false; // Reset verification when email changes
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Company Information
              _buildSectionTitle('Company Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter your company name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  hintText: 'Enter your job title',
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your designation';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _companyIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID (Optional)',
                  hintText: 'Enter your employee ID',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _companyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Company Phone (Optional)',
                  hintText: 'Enter company contact number',
                  prefixIcon: Icon(Icons.phone_in_talk),
                ),
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              // Verification Level Info
              _buildVerificationInfo(),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : const Text('Create Digital Card'),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryBlue,
                  width: 3,
                ),
                color: Colors.grey[100],
              ),
              child: _selectedProfileImage != null
                  ? ClipOval(
                      child: Image.network(
                        _selectedProfileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickProfileImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Add Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.grey[400],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  // Removed unused phone verification methods - phone is verified at login

  Widget _buildVerificationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.verifiedYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.verifiedYellow.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.verifiedYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Verification Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verifiedYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your card will start with Basic Verification. You can upgrade it later by uploading documents and getting colleague endorsements.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.verifiedYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BASIC VERIFIED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Phone verified only',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Email verification methods
  Future<void> _sendEmailVerification() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Send email verification using Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification email sent to ${_emailController.text}'),
              backgroundColor: Colors.blue,
              action: SnackBarAction(
                label: 'Check Email',
                onPressed: () {
                  // Could open email app here
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Show loading indicator
        setState(() {
          _isLoading = true;
        });
        
        try {
          // Upload image to Firebase Storage
          final File imageFile = File(image.path);
          final String userId = context.read<app_auth.AuthProvider>().currentUser?.id ?? 'unknown';
          final String fileName = 'profile-photos/$userId/${const Uuid().v4()}.jpg';
          final Reference ref = FirebaseStorage.instance.ref().child(fileName);
          
          print('Uploading image to: $fileName');
          
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
          
          print('Image uploaded successfully: $downloadUrl');
          
          setState(() {
            _selectedProfileImage = downloadUrl;
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (uploadError) {
          print('Upload error: $uploadError');
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $uploadError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if phone verification is required and completed
    // Phone is already verified at login - no need to check

    setState(() {
      _isLoading = true;
    });

    try {
      // For new users, update their profile with the entered name
      if (_isNewUser) {
        final authProvider = context.read<app_auth.AuthProvider>();
        final newName = _nameController.text.trim();
        
        // Update user profile with the new name
        await authProvider.updateProfile(fullName: newName);
        
        // Show success message for profile update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated with name: $newName'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      final card = UserCard(
        id: const Uuid().v4(),
        userId: FirebaseService.getCurrentUser()?.uid ?? 'unknown',
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePhotoUrl: _selectedProfileImage,
        companyName: _companyController.text.trim(),
        designation: _designationController.text.trim(),
        companyId: _companyIdController.text.trim().isNotEmpty 
            ? _companyIdController.text.trim() 
            : null,
        companyPhone: _companyPhoneController.text.trim().isNotEmpty 
            ? _companyPhoneController.text.trim() 
            : null,
        companyEmail: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() 
            : null,
        verificationLevel: VerificationLevel.basic,
        isCompanyVerified: false,
        createdAt: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        version: 1,
        isActive: true,
      );

      final success = await context.read<CardProvider>().createCard(card);
      
      if (success && mounted) {
        // Validate employee ID if entered
        if (_companyIdController.text.trim().isNotEmpty) {
          final validationResult = await EmployeeInvitationService.validateEmployeeId(
            enteredEmployeeId: _companyIdController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
          
          if (validationResult != null) {
            if (validationResult['status'] == 'expired') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Employee invitation has expired'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              // Notify company about card creation
              await EmployeeInvitationService.notifyCompanyAboutEmployeeCard(
                companyId: validationResult['companyId'],
                employeeName: _nameController.text.trim(),
                employeePhone: _phoneController.text.trim(),
                enteredEmployeeId: validationResult['enteredEmployeeId'],
                correctEmployeeId: validationResult['correctEmployeeId'],
                isMatch: validationResult['isMatch'],
              );
            }
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Digital card created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<CardProvider>().error ?? 'Failed to create card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
