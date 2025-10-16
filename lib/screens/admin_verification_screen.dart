import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  String _selectedStatus = 'pending';
  String? _selectedDocumentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification Queue'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('Rejected'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _selectedStatus.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(_selectedStatus),
                  color: _getStatusColor(_selectedStatus),
                ),
                const SizedBox(width: 8),
                Text(
                  'Showing $_selectedStatus documents',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Verification queue
          Expanded(
            child: _buildVerificationQueue(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationQueue() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('verification_requests')
          .where('status', isEqualTo: _selectedStatus)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final documents = snapshot.data?.docs ?? [];
        
        if (documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No $_selectedStatus documents',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildVerificationCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildVerificationCard(String docId, Map<String, dynamic> data) {
    final isSelected = _selectedDocumentId == docId;
    
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDocumentId = isSelected ? null : docId;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['status'].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTimestamp(data['timestamp']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // User info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      (data['userName'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['userName'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          data['companyName'] ?? 'Unknown Company',
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
              
              const SizedBox(height: 12),
              
              // Document type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDocumentTypeTitle(data['type']),
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Expanded document view
              if (isSelected) ...[
                const SizedBox(height: 16),
                _buildDocumentViewer(data['fileUrl']),
                const SizedBox(height: 16),
                _buildActionButtons(docId, data),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentViewer(String fileUrl) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Failed to load document'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(String docId, Map<String, dynamic> data) {
    if (data['status'] != 'pending') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getStatusColor(data['status']).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              data['status'] == 'approved' ? Icons.check_circle : Icons.cancel,
              color: _getStatusColor(data['status']),
            ),
            const SizedBox(width: 8),
            Text(
              'Document ${data['status']}',
              style: TextStyle(
                color: _getStatusColor(data['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _approveDocument(docId),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verifiedGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _rejectDocument(docId),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveDocument(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('verification_requests')
          .doc(docId)
          .update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'admin', // In real app, use actual admin ID
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectDocument(String docId) async {
    // Show rejection reason dialog
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Document unclear, Wrong document type',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, reasonController.text.trim());
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        // Get document data first to send notification
        final doc = await FirebaseFirestore.instance
            .collection('verification_requests')
            .doc(docId)
            .get();
        
        final docData = doc.data();
        if (docData == null) return;
        
        await FirebaseFirestore.instance
            .collection('verification_requests')
            .doc(docId)
            .update({
          'status': 'rejected',
          'rejectionReason': reason,
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': 'admin',
        });

        // Send notification to user
        await _sendRejectionNotification(
          userId: docData['userId'],
          userName: docData['userName'],
          documentType: docData['type'],
          reason: reason,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document rejected and user notified'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rejecting document: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _sendRejectionNotification({
    required String userId,
    required String userName,
    required String documentType,
    required String reason,
  }) async {
    try {
      // Create notification document
      await FirebaseFirestore.instance.collection('user_notifications').add({
        'userId': userId,
        'type': 'document_rejected',
        'title': 'Document Verification Rejected',
        'message': 'Your $documentType was rejected. Reason: $reason',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'data': {
          'documentType': documentType,
          'rejectionReason': reason,
        },
      });
      
      print('Rejection notification sent to user: $userName');
    } catch (e) {
      print('Error sending rejection notification: $e');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.verifiedYellow;
      case 'approved':
        return AppTheme.verifiedGreen;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  String _getDocumentTypeTitle(String type) {
    switch (type) {
      case 'companyId':
        return 'Company ID Card';
      case 'offerLetter':
        return 'Offer Letter';
      case 'salarySlip':
        return 'Salary Slip';
      case 'workEmail':
        return 'Work Email Screenshot';
      default:
        return type;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Unknown time';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
