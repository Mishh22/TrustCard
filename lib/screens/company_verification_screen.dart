import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/company_verification_service.dart';
import '../models/company_verification_request.dart';

class CompanyVerificationScreen extends StatefulWidget {
  const CompanyVerificationScreen({super.key});

  @override
  State<CompanyVerificationScreen> createState() => _CompanyVerificationScreenState();
}

class _CompanyVerificationScreenState extends State<CompanyVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  
  File? _businessPhoto;
  File? _gstCertificate;
  File? _panCertificate;
  bool _isLoading = false;
  CompanyVerificationRequest? _existingRequest;

  @override
  void initState() {
    super.initState();
    _loadExistingRequest();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessAddressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _panNumberController.dispose();
    _gstNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRequest() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final request = await CompanyVerificationService.getUserVerificationRequest(
        authProvider.currentUser!.id,
      );
      if (mounted) {
        setState(() {
          _existingRequest = request;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is already verified
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser?.isCompanyVerified == true) {
      // User is already verified, redirect to company admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/company-admin');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Verification'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company Verification',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get verified by your company for enhanced trust',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
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
            
            const SizedBox(height: 24),
            
            // Benefits
            _buildBenefitsSection(),
            
            const SizedBox(height: 24),
            
            // Status or Form
            _existingRequest != null && _existingRequest!.status != CompanyVerificationStatus.withdrawn
                ? _buildStatusSection() 
                : _buildVerificationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits of Company Verification',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildBenefitItem(
          Icons.verified_user,
          'Enhanced Trust',
          'Your company\'s verification adds credibility to your profile',
        ),
        
        _buildBenefitItem(
          Icons.business_center,
          'Professional Recognition',
          'Show your official employment status',
        ),
        
        _buildBenefitItem(
          Icons.security,
          'Secure Verification',
          'Company-controlled verification process',
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
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
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _existingRequest!.status == CompanyVerificationStatus.approved
                      ? Icons.check_circle
                      : _existingRequest!.status == CompanyVerificationStatus.rejected
                          ? Icons.cancel
                          : Icons.pending,
                  color: _existingRequest!.status == CompanyVerificationStatus.approved
                      ? Colors.green
                      : _existingRequest!.status == CompanyVerificationStatus.rejected
                          ? Colors.red
                          : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Verification Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatusItem('Company', _existingRequest!.companyName),
            _buildStatusItem('Status', _getStatusText(_existingRequest!.status)),
            _buildStatusItem('Submitted', _formatDate(_existingRequest!.submittedAt)),
            
            if (_existingRequest!.reviewedAt != null)
              _buildStatusItem('Reviewed', _formatDate(_existingRequest!.reviewedAt!)),
            
            if (_existingRequest!.rejectionReason != null)
              _buildStatusItem('Reason', _existingRequest!.rejectionReason!),
            
            const SizedBox(height: 16),
            
            if (_existingRequest!.status == CompanyVerificationStatus.pending)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your request is under review. We typically review requests within a few business days.',
                            style: TextStyle(color: Colors.orange[700], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _withdrawRequest,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Withdraw Request'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(CompanyVerificationStatus status) {
    switch (status) {
      case CompanyVerificationStatus.pending:
        return 'Under Review';
      case CompanyVerificationStatus.approved:
        return 'Approved ✅';
      case CompanyVerificationStatus.rejected:
        return 'Rejected ❌';
      case CompanyVerificationStatus.withdrawn:
        return 'Withdrawn 📤';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _withdrawRequest() async {
    if (_existingRequest == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Request'),
        content: const Text(
          'Are you sure you want to withdraw your company verification request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await CompanyVerificationService.withdrawRequest(
        requestId: _existingRequest!.id,
        userId: authProvider.currentUser!.id,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Refresh the request data
          await _loadExistingRequest();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request withdrawn successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to withdraw request. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildVerificationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Company Verification',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Company Name
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name *',
              hintText: 'Enter your company name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter company name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Business Address
          TextFormField(
            controller: _businessAddressController,
            decoration: const InputDecoration(
              labelText: 'Business Address *',
              hintText: 'Enter complete business address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter business address';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Phone Number
          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: '+91 9876543210',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length < 10) {
                return 'Please enter valid phone number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              hintText: 'your.email@company.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email';
              }
              if (!value.contains('@')) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Contact Person
          TextFormField(
            controller: _contactPersonController,
            decoration: const InputDecoration(
              labelText: 'Contact Person Name *',
              hintText: 'Enter contact person name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter contact person name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // GST Number
          TextFormField(
            controller: _gstNumberController,
            decoration: const InputDecoration(
              labelText: 'GST Number (Optional)',
              hintText: '22ABCDE1234F1Z5',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.receipt_long),
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (value.length < 15) {
                  return 'GST number should be 15 characters';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // PAN Number
          TextFormField(
            controller: _panNumberController,
            decoration: const InputDecoration(
              labelText: 'PAN Number (Optional)',
              hintText: 'ABCDE1234F',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (value.length != 10) {
                  return 'PAN number should be 10 characters';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Photo Upload Section
          Text(
            'Required Documents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Business Photo
          _buildPhotoUpload(
            'Business Photo *',
            'Take photo of your shop/business signboard',
            _businessPhoto,
            Icons.store,
            () => _pickImage(ImageSource.camera, true),
          ),
          
          const SizedBox(height: 16),
          
                // GST Certificate
                _buildFileUpload(
                  'GST Certificate (Preferred)',
                  'Upload GST registration certificate (Image or PDF)',
                  _gstCertificate,
                  Icons.receipt_long,
                  () => _pickGstFile(),
                ),

                const SizedBox(height: 16),

                // PAN Certificate
                _buildFileUpload(
                  'PAN Certificate (If no GST)',
                  'Upload PAN card or certificate (Image or PDF)',
                  _panCertificate,
                  Icons.credit_card,
                  () => _pickPanFile(),
                ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitVerificationRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Verification Request',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload(String title, String description, File? photo, IconData icon, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          
          if (photo != null) ...[
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  photo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          ElevatedButton.icon(
            key: ValueKey('photo_upload_${title.replaceAll(' ', '_')}'),
            onPressed: onTap,
            icon: Icon(photo != null ? Icons.refresh : Icons.camera_alt),
            label: Text(photo != null ? 'Change Photo' : 'Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUpload(
    String title,
    String subtitle,
    File? file,
    IconData icon,
    VoidCallback onPickFile,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (file == null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('file_upload_${title.replaceAll(' ', '_')}'),
                onPressed: onPickFile,
                icon: Icon(icon),
                label: const Text('Upload File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        file.path.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file.path.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    key: ValueKey('file_change_${title.replaceAll(' ', '_')}'),
                    onPressed: onPickFile,
                    icon: const Icon(Icons.change_circle),
                    label: const Text('Change File'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isBusinessPhoto) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isBusinessPhoto) {
            _businessPhoto = File(image.path);
          } else {
            // This method is now only used for business photos
            _businessPhoto = File(image.path);
          }
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickGstImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _gstCertificate = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking GST image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

        Future<void> _pickPanImage(ImageSource source) async {
          try {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: source,
              maxWidth: 1920,
              maxHeight: 1080,
              imageQuality: 85,
            );
            
            if (image != null) {
              setState(() {
                _panCertificate = File(image.path);
              });
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error picking PAN image: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        Future<void> _pickGstFile() async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
            );
            
            if (result != null && result.files.single.path != null) {
              setState(() {
                _gstCertificate = File(result.files.single.path!);
              });
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error picking GST file: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        Future<void> _pickPanFile() async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
            );
            
            if (result != null && result.files.single.path != null) {
              setState(() {
                _panCertificate = File(result.files.single.path!);
              });
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error picking PAN file: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

  Future<void> _submitVerificationRequest() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if business photo is selected
    if (_businessPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take photo of your business'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if at least one certificate is uploaded
    if (_gstCertificate == null && _panCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload either GST certificate or PAN certificate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Submit verification request
      final requestId = await CompanyVerificationService.submitVerificationRequest(
        userId: authProvider.currentUser!.id,
        companyName: _companyNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        businessPhoto: _businessPhoto!,
        panNumber: _panNumberController.text.trim().isNotEmpty ? _panNumberController.text.trim() : null,
        gstNumber: _gstNumberController.text.trim().isNotEmpty ? _gstNumberController.text.trim() : null,
        gstCertificate: _gstCertificate,
        panCertificate: _panCertificate,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Request Submitted Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your company verification request has been submitted.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Request ID: $requestId',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ll review your request within a few business days and notify you via email and app notification.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop(); // Go back to profile
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
