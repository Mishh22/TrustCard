import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/verification_document.dart';
import '../models/user_card.dart';
import '../providers/document_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class DocumentManagementScreen extends StatefulWidget {
  final UserCard card;

  const DocumentManagementScreen({super.key, required this.card});

  @override
  State<DocumentManagementScreen> createState() => _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await documentProvider.loadCardDocuments(
        authProvider.currentUser!.id,
        widget.card.id,
      );
    }
  }

  Future<void> _pickAndUploadDocument(DocumentType documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final documentProvider = Provider.of<DocumentProvider>(context, listen: false);

        if (authProvider.currentUser == null) {
          _showMessage('Please log in to upload documents', isError: true);
          return;
        }

        final success = await documentProvider.uploadDocument(
          userId: authProvider.currentUser!.id,
          cardId: widget.card.id,
          file: file,
          documentType: documentType,
        );

        if (mounted) {
          if (success) {
            _showMessage('Document uploaded successfully!');
          } else {
            _showMessage(
              documentProvider.error ?? 'Failed to upload document',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      _showMessage('Error picking file: $e', isError: true);
    }
  }

  Future<void> _deleteDocument(VerificationDocument document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete ${document.documentType.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);

      if (authProvider.currentUser == null) return;

      final success = await documentProvider.deleteDocument(
        userId: authProvider.currentUser!.id,
        cardId: widget.card.id,
        documentId: document.id,
      );

      if (mounted) {
        if (success) {
          _showMessage('Document deleted successfully!');
        } else {
          _showMessage(
            documentProvider.error ?? 'Failed to delete document',
            isError: true,
          );
        }
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Documents'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, child) {
          if (documentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = documentProvider.getDocumentsForCard(widget.card.id);

          return RefreshIndicator(
            onRefresh: _loadDocuments,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardInfoCard(),
                const SizedBox(height: 24),
                _buildDocumentTypesSection(documentProvider, documents),
                if (documents.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildUploadedDocumentsSection(documents),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Documents for:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.card.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.card.companyName ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (widget.card.designation != null && widget.card.designation!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.card.designation!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypesSection(
    DocumentProvider documentProvider,
    List<VerificationDocument> documents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Types',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload one document per type. If you need to upload front and back, please merge them into a single file.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ...DocumentType.values.map((type) {
          final hasDocument = documentProvider.hasDocumentType(widget.card.id, type);
          return _buildDocumentTypeCard(type, hasDocument);
        }),
      ],
    );
  }

  Widget _buildDocumentTypeCard(DocumentType type, bool hasDocument) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getDocumentIcon(type),
          color: hasDocument ? Colors.green : AppTheme.primaryBlue,
        ),
        title: Text(type.displayName),
        subtitle: hasDocument
            ? const Text('Uploaded', style: TextStyle(color: Colors.green))
            : const Text('Not uploaded'),
        trailing: hasDocument
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton.icon(
                onPressed: () => _pickAndUploadDocument(type),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildUploadedDocumentsSection(List<VerificationDocument> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uploaded Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...documents.map((doc) => _buildDocumentCard(doc)),
      ],
    );
  }

  Widget _buildDocumentCard(VerificationDocument document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getDocumentIcon(document.documentType),
          color: _getStatusColor(document.verificationStatus),
        ),
        title: Text(document.documentType.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getStatusIcon(document.verificationStatus),
                  size: 16,
                  color: _getStatusColor(document.verificationStatus),
                ),
                const SizedBox(width: 4),
                Text(
                  document.verificationStatus.displayName,
                  style: TextStyle(
                    color: _getStatusColor(document.verificationStatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocumentDetail('File Name', document.fileName),
                _buildDocumentDetail('File Size', document.formattedFileSize),
                _buildDocumentDetail(
                  'Uploaded',
                  _formatDate(document.uploadedAt),
                ),
                _buildDocumentDetail(
                  'Status',
                  document.isSynced
                      ? 'Synced (Local & Cloud)'
                      : document.isCloudOnly
                          ? 'Cloud Only'
                          : 'Local Only',
                ),
                if (document.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rejection Reason:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(document.rejectionReason!),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteDocument(document),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.companyId:
        return Icons.badge;
      case DocumentType.aadhaar:
        return Icons.credit_card;
      case DocumentType.pan:
        return Icons.account_balance_wallet;
      case DocumentType.salarySlip:
        return Icons.receipt_long;
      case DocumentType.offerLetter:
        return Icons.description;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.schedule;
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.rejected:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

