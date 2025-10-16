import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/document_provider.dart';
import '../models/user_card.dart';
import '../models/verification_document.dart' as models;
import '../utils/app_theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<DocumentType> _uploadedDocuments = [];
  bool _isLoading = false;
  bool _isCompressing = false;
  UserCard? _selectedCard;

  @override
  void initState() {
    super.initState();
    // Load the first card by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardProvider = context.read<CardProvider>();
      if (cardProvider.cards.isNotEmpty) {
        setState(() {
          _selectedCard = cardProvider.cards.first;
        });
        _loadDocuments();
      }
    });
  }

  void _loadDocuments() {
    if (_selectedCard == null) return;
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      context.read<DocumentProvider>().loadCardDocuments(userId, _selectedCard!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitDocuments,
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
                              'Upload Documents',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Upload documents to get verified by colleagues and build trust',
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
            
            // Card Selector
            _buildCardSelector(),
            
            const SizedBox(height: 24),
            
            // Current Status
            if (_selectedCard != null) _buildCurrentStatus(),
            
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

  Widget _buildCardSelector() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        final cards = cardProvider.cards;
        
        if (cards.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Please create a card first to upload documents',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select Card to Verify',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserCard>(
                      value: _selectedCard,
                      isExpanded: true,
                      hint: const Text('Select a card'),
                      items: cards.map((card) {
                        return DropdownMenuItem<UserCard>(
                          value: card,
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: AppTheme.primaryBlue, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      card.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (card.companyName != null)
                                      Text(
                                        card.companyName!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (card) {
                        setState(() {
                          _selectedCard = card;
                        });
                        _loadDocuments();
                      },
                    ),
                  ),
                ),
                if (_selectedCard != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Documents will be uploaded for: ${_selectedCard!.fullName}',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
          onTap: (_isLoading || _isCompressing) ? null : () => _uploadDocument(type),
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
      // Show upload options (camera, gallery, or PDF)
      final uploadType = await _showUploadOptions();
      if (uploadType == null) return;

      File? fileToUpload;
      String? fileName;
      String? contentType;
      
      if (uploadType == 'pdf') {
        // Pick PDF file
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.path != null) {
          fileToUpload = File(result.files.single.path!);
          fileName = result.files.single.name;
          contentType = 'application/pdf';
          
          // Validate PDF file size (max 10MB)
          final fileSize = await fileToUpload.length();
          if (fileSize > 10 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF file too large. Please upload a file smaller than 10MB.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      } else {
        // Pick image from camera or gallery
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: uploadType == 'camera' ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 2000,
          maxHeight: 2000,
          imageQuality: 85,
        );
        
        if (image != null) {
          final file = File(image.path);
          
          // Validate image file size (max 5MB)
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image file too large. Please upload a file smaller than 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Show compression loading
          setState(() {
            _isCompressing = true;
          });
          
          // Compress image for faster upload
          fileToUpload = await _compressImage(file);
          fileName = image.name;
          contentType = 'image/jpeg';
          
          setState(() {
            _isCompressing = false;
          });
        }
      }
      
      if (fileToUpload != null) {
        // Upload to Firebase Storage with immutable path
        final success = await _uploadToFirebase(fileToUpload, type, fileName: fileName, contentType: contentType);
        
        if (success) {
          setState(() {
            if (!_uploadedDocuments.contains(type)) {
              _uploadedDocuments.add(type);
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getDocumentTitle(type)} uploaded successfully! Awaiting verification.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showUploadOptions() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choose Upload Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture document with camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select image from gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Upload PDF'),
              subtitle: const Text('Select PDF document (max 10MB)'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _uploadToFirebase(File file, DocumentType type, {String? fileName, String? contentType}) async {
    try {
      final userId = context.read<AuthProvider>().currentUser?.id ?? 'unknown';
      
      // Rate limiting removed - using new document management system
      
      // Create immutable document ID
      final documentId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Determine file extension based on content type
      final fileExtension = contentType == 'application/pdf' ? 'pdf' : 'jpg';
      
      // Upload to Firebase Storage with metadata
      final ref = FirebaseStorage.instance
          .ref()
          .child('verification-docs/$documentId/${type.name}.$fileExtension');
      
      final metadata = SettableMetadata(
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'documentType': type.name,
          'userName': context.read<AuthProvider>().currentUser?.fullName ?? 'Unknown',
          'fileName': fileName ?? 'document.$fileExtension',
        },
        contentType: contentType ?? 'image/jpeg',
      );
      
      await ref.putFile(file, metadata);
      final downloadUrl = await ref.getDownloadURL();
      
      // Create verification request in Firestore
      await FirebaseFirestore.instance.collection('verification_requests').add({
        'userId': userId,
        'documentId': documentId,
        'type': type.name,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'fileUrl': downloadUrl,
        'userName': context.read<AuthProvider>().currentUser?.fullName ?? 'Unknown',
        'companyName': context.read<AuthProvider>().currentUser?.companyName ?? 'Unknown',
      });
      
      return true;
    } catch (e) {
      print('Error uploading to Firebase: $e');
      return false;
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      // Read image bytes
      final bytes = await file.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        print('Failed to decode image, returning original');
        return file;
      }
      
      // Resize and compress
      final resized = img.copyResize(image, width: 1200); // Good resolution for manual review
      final compressed = img.encodeJpg(resized, quality: 85); // Good quality/size balance
      
      // Write compressed image
      final tempDir = await getTemporaryDirectory();
      final compressedPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressed);
      
      // Check compression ratio
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
      
      print('Image compression: ${originalSize / 1024}KB → ${compressedSize / 1024}KB (${compressionRatio}% reduction)');
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
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
      // Documents are already uploaded to Firebase with verification requests
      // No need to simulate verification - it's handled by admin dashboard
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents submitted for manual verification! You will be notified when reviewed.'),
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
    }
  }
}

enum DocumentType {
  companyId,
  offerLetter,
  salarySlip,
}

