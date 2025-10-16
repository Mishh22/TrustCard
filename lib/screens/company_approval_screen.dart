import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/company_approval_request.dart';
import '../services/company_approval_service.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

/// Screen for company admins to review and approve/reject employee card requests
class CompanyApprovalScreen extends StatefulWidget {
  const CompanyApprovalScreen({super.key});

  @override
  State<CompanyApprovalScreen> createState() => _CompanyApprovalScreenState();
}

class _CompanyApprovalScreenState extends State<CompanyApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCompanyId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null && currentUser.companyId != null) {
      setState(() {
        _companyId = currentUser.companyId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Employee Approvals'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No company associated with this account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Approvals'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Pending',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Approved',
            ),
            Tab(
              icon: Icon(Icons.cancel),
              text: 'Rejected',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(CompanyApprovalStatus.pending),
          _buildRequestsList(CompanyApprovalStatus.approved),
          _buildRequestsList(CompanyApprovalStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildRequestsList(CompanyApprovalStatus status) {
    return StreamBuilder<List<CompanyApprovalRequest>>(
      stream: CompanyApprovalService.getAllRequests(_companyId!, status: status, limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyIcon(status),
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(status),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(CompanyApprovalRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(request.status),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (request.designation != null && request.designation!.isNotEmpty)
                        Text(
                          request.designation!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(request.status),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            _buildDetailRow(Icons.phone, request.requesterPhone),
            _buildDetailRow(Icons.business, request.companyName),
            _buildDetailRow(
              Icons.access_time,
              'Requested ${_formatDate(request.createdAt)}',
            ),

            if (request.reviewedAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.event_available,
                'Reviewed ${_formatDate(request.reviewedAt!)}',
              ),
            ],

            if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Rejection Reason:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.rejectionReason!,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons for pending requests
            if (request.status == CompanyApprovalStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.verifiedGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CompanyApprovalStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return Colors.orange;
      case CompanyApprovalStatus.approved:
        return AppTheme.verifiedGreen;
      case CompanyApprovalStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return Icons.pending_actions;
      case CompanyApprovalStatus.approved:
        return Icons.check_circle;
      case CompanyApprovalStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return 'PENDING';
      case CompanyApprovalStatus.approved:
        return 'APPROVED';
      case CompanyApprovalStatus.rejected:
        return 'REJECTED';
    }
  }

  IconData _getEmptyIcon(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return Icons.inbox;
      case CompanyApprovalStatus.approved:
        return Icons.check_circle_outline;
      case CompanyApprovalStatus.rejected:
        return Icons.block;
    }
  }

  String _getEmptyMessage(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return 'No pending approval requests';
      case CompanyApprovalStatus.approved:
        return 'No approved requests yet';
      case CompanyApprovalStatus.rejected:
        return 'No rejected requests';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _approveRequest(CompanyApprovalRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text(
          'Are you sure you want to approve ${request.requesterName}\'s request to join your company?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.verifiedGreen,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await CompanyApprovalService.approveRequest(request.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${request.requesterName} approved successfully!'
                  : 'Failed to approve request',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRejectDialog(CompanyApprovalRequest request) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject ${request.requesterName}\'s request?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await CompanyApprovalService.rejectRequest(
        request.id,
        rejectionReason: reasonController.text.trim().isNotEmpty 
            ? reasonController.text.trim() 
            : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${request.requesterName} rejected'
                  : 'Failed to reject request',
            ),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
      }
    }
  }
}

