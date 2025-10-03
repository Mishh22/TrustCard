import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<DocumentType> _uploadedDocuments = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitDocuments,
            child: const Text('Submit'),
          ),
        ],
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
                  colors: [
                    AppTheme.verifiedGreen,
                    Color(0xFF059669),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document Verification',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Upload documents to increase your trust level',
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
            
            // Current Status
            _buildCurrentStatus(),
            
            const SizedBox(height: 24),
            
            // Document Types
            _buildDocumentTypes(),
            
            const SizedBox(height: 24),
            
            // Uploaded Documents
            if (_uploadedDocuments.isNotEmpty) _buildUploadedDocuments(),
            
            const SizedBox(height: 24),
            
            // Benefits
            _buildBenefits(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.verifiedYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    color: AppTheme.verifiedYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status: Basic Verified',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phone number verified only',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.verifiedYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'BASIC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            LinearProgressIndicator(
              value: 0.3, // Basic verification = 30%
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.verifiedYellow),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Upload documents to reach 60% verification',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDocumentCard(
          'Company ID Card',
          'Upload your official company ID card',
          Icons.badge,
          AppTheme.verifiedGreen,
          DocumentType.companyId,
        ),
        
        _buildDocumentCard(
          'Offer Letter',
          'Upload your job offer or appointment letter',
          Icons.description,
          AppTheme.verifiedBlue,
          DocumentType.offerLetter,
        ),
        
        _buildDocumentCard(
          'Salary Slip',
          'Upload your recent salary slip (last 3 months)',
          Icons.receipt,
          AppTheme.verifiedYellow,
          DocumentType.salarySlip,
        ),
        
        _buildDocumentCard(
          'Work Email Screenshot',
          'Screenshot of work email or WhatsApp conversation',
          Icons.email,
          AppTheme.primaryBlue,
          DocumentType.workEmail,
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    String title,
    String description,
    IconData icon,
    Color color,
    DocumentType type,
  ) {
    final isUploaded = _uploadedDocuments.contains(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () => _uploadDocument(type),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUploaded 
                        ? AppTheme.verifiedGreen.withOpacity(0.1)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_circle : icon,
                    color: isUploaded ? AppTheme.verifiedGreen : color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUploaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.verifiedGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'UPLOADED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.upload,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ..._uploadedDocuments.map((type) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.verifiedGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.verifiedGreen,
                  size: 20,
                ),
              ),
              title: Text(_getDocumentTitle(type)),
              subtitle: const Text('Document verified'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeDocument(type),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.verifiedGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.verifiedGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Benefits of Document Verification',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verifiedGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildBenefitItem(
            'Higher Trust Score',
            'Customers will trust your identity more',
          ),
          _buildBenefitItem(
            'Priority in Listings',
            'Your profile appears higher in search results',
          ),
          _buildBenefitItem(
            'Green Verification Badge',
            'Get the "Document Verified" badge on your card',
          ),
          _buildBenefitItem(
            'Better Ratings',
            'Customers are more likely to rate you highly',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.verifiedGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(DocumentType type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          if (!_uploadedDocuments.contains(type)) {
            _uploadedDocuments.add(type);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentTitle(type)} uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeDocument(DocumentType type) {
    setState(() {
      _uploadedDocuments.remove(type);
    });
  }

  Future<void> _submitDocuments() async {
    if (_uploadedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one document'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate document verification process
      await Future.delayed(const Duration(seconds: 2));
      
      // Update user's verification level
      final authProvider = context.read<AuthProvider>();
      final cardProvider = context.read<CardProvider>();
      
      if (authProvider.currentUser != null) {
        final updatedCard = authProvider.currentUser!.copyWith(
          verificationLevel: VerificationLevel.document,
          uploadedDocuments: _uploadedDocuments.map((e) => e.name).toList(),
        );
        
        await cardProvider.updateCard(updatedCard);
        await authProvider.updateProfile();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents submitted for verification!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit documents: $e'),
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

  String _getDocumentTitle(DocumentType type) {
    switch (type) {
      case DocumentType.companyId:
        return 'Company ID Card';
      case DocumentType.offerLetter:
        return 'Offer Letter';
      case DocumentType.salarySlip:
        return 'Salary Slip';
      case DocumentType.workEmail:
        return 'Work Email Screenshot';
    }
  }
}

enum DocumentType {
  companyId,
  offerLetter,
  salarySlip,
  workEmail,
}
