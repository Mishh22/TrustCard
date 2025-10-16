import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../services/company_verification_service.dart';

class CompanyAdminScreen extends StatefulWidget {
  const CompanyAdminScreen({super.key});

  @override
  State<CompanyAdminScreen> createState() => _CompanyAdminScreenState();
}

class _CompanyAdminScreenState extends State<CompanyAdminScreen> {
  String _selectedTab = 'pending';
  final List<VerificationRequest> _pendingRequests = [];
  final List<VerificationRequest> _approvedRequests = [];
  final List<VerificationRequest> _rejectedRequests = [];

  @override
  void initState() {
    super.initState();
    _loadVerificationRequests();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is company verified
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser?.isCompanyVerified != true) {
      // User is not verified, redirect to verification screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/company-verification');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/company-employees'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Company Info Header
          _buildCompanyHeader(currentUser),
          
          // Tab Navigation
          _buildTabNavigation(),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader(UserCard? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.verifiedGold,
            Color(0xFFD97706),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentUser?.companyName ?? 'Company'} Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage employee verification requests',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'COMPANY VERIFIED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab('pending', 'Pending', _pendingRequests.length),
          _buildTab('approved', 'Approved', _approvedRequests.length),
          _buildTab('rejected', 'Rejected', _rejectedRequests.length),
        ],
      ),
    );
  }

  Widget _buildTab(String tab, String label, int count) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'pending':
        return _buildPendingRequests();
      case 'approved':
        return _buildApprovedRequests();
      case 'rejected':
        return _buildRejectedRequests();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPendingRequests() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState(
        'No Pending Requests',
        'All verification requests have been processed',
        Icons.check_circle_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _buildRequestCard(request, true);
      },
    );
  }

  Widget _buildApprovedRequests() {
    if (_approvedRequests.isEmpty) {
      return _buildEmptyState(
        'No Approved Requests',
        'Approved requests will appear here',
        Icons.verified,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _approvedRequests.length,
      itemBuilder: (context, index) {
        final request = _approvedRequests[index];
        return _buildRequestCard(request, false);
      },
    );
  }

  Widget _buildRejectedRequests() {
    if (_rejectedRequests.isEmpty) {
      return _buildEmptyState(
        'No Rejected Requests',
        'Rejected requests will appear here',
        Icons.cancel_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rejectedRequests.length,
      itemBuilder: (context, index) {
        final request = _rejectedRequests[index];
        return _buildRequestCard(request, false);
      },
    );
  }

  Widget _buildRequestCard(VerificationRequest request, bool isPending) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: request.userCard.profilePhotoUrl != null
                      ? NetworkImage(request.userCard.profilePhotoUrl!)
                      : null,
                  child: request.userCard.profilePhotoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userCard.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.userCard.designation ?? 'Unknown Role',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Request Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Company', request.userCard.companyName ?? 'Unknown'),
                  _buildDetailRow('Employee ID', request.userCard.companyId ?? 'Not provided'),
                  _buildDetailRow('Phone', request.userCard.phoneNumber), // Show full phone number
                  _buildDetailRow('Requested', _formatDate(request.requestedAt)),
                  if (request.documents.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Uploaded Documents:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...request.documents.map((doc) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        '• $doc',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            ),
            
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.verifiedGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Status change buttons for approved/rejected requests
              const SizedBox(height: 12),
              Row(
                children: [
                  if (request.status == 'approved') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _changeStatus(request, 'rejected'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _changeStatus(request, 'pending'),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Re-review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ] else if (request.status == 'rejected') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _changeStatus(request, 'approved'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.verifiedGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _changeStatus(request, 'pending'),
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const Text('Re-review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _loadVerificationRequests() {
    // Mock data - in real app, load from API
    setState(() {
      _pendingRequests.addAll([
        VerificationRequest(
          id: 'req_1',
          userCard: UserCard(
            id: 'card_1',
            userId: 'user_1',
            fullName: 'Rahul Kumar',
            phoneNumber: '+91 9876543210',
            companyName: 'Company 1 Pvt Ltd',
            designation: 'Delivery Partner',
            companyId: 'SWG12345',
            verificationLevel: VerificationLevel.document,
            isCompanyVerified: false,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            version: 1,
            isActive: true,
            uploadedDocuments: ['id_card.jpg', 'offer_letter.pdf'],
          ),
          status: 'pending',
          requestedAt: DateTime.now().subtract(const Duration(days: 1)),
          documents: ['Company ID Card', 'Offer Letter'],
        ),
        VerificationRequest(
          id: 'req_2',
          userCard: UserCard(
            id: 'card_2',
            userId: 'user_2',
            fullName: 'Priya Sharma',
            phoneNumber: '+91 9876543211',
            companyName: 'Company 1 Pvt Ltd',
            designation: 'Delivery Executive',
            companyId: 'SWG67890',
            verificationLevel: VerificationLevel.peer,
            isCompanyVerified: false,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            version: 1,
            isActive: true,
            verifiedByColleagues: ['colleague1', 'colleague2'],
          ),
          status: 'pending',
          requestedAt: DateTime.now().subtract(const Duration(days: 2)),
          documents: ['Salary Slip', 'Work Email Screenshot'],
        ),
      ]);
    });
  }

  void _approveRequest(VerificationRequest request) async {
    // Update database first
    final success = await CompanyVerificationService.approveRequest(
      requestId: request.id,
      reviewedBy: 'admin', // TODO: Get from current user
    );
    
    if (success) {
      // Update local state after successful database update
      setState(() {
        _pendingRequests.remove(request);
        _approvedRequests.add(request.copyWith(status: 'approved'));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.userCard.fullName} approved for company verification'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectRequest(VerificationRequest request) async {
    // Update database first
    final success = await CompanyVerificationService.rejectRequest(
      requestId: request.id,
      reviewedBy: 'admin', // TODO: Get from current user
      rejectionReason: 'Company admin rejected the request',
    );
    
    if (success) {
      // Update local state after successful database update
      setState(() {
        _pendingRequests.remove(request);
        _rejectedRequests.add(request.copyWith(status: 'rejected'));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.userCard.fullName} verification rejected'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changeStatus(VerificationRequest request, String newStatus) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status'),
        content: Text('Are you sure you want to change status to $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Update database first
      final success = await CompanyVerificationService.changeRequestStatus(
        requestId: request.id,
        newStatus: newStatus,
        reviewedBy: 'admin', // TODO: Get from current user
      );
      
      if (success) {
        // Update local state after successful database update
        setState(() {
          if (newStatus == 'pending') {
            _pendingRequests.add(request.copyWith(status: newStatus));
            _approvedRequests.removeWhere((r) => r.id == request.id);
            _rejectedRequests.removeWhere((r) => r.id == request.id);
          } else if (newStatus == 'approved') {
            _approvedRequests.add(request.copyWith(status: newStatus));
            _pendingRequests.removeWhere((r) => r.id == request.id);
            _rejectedRequests.removeWhere((r) => r.id == request.id);
          } else if (newStatus == 'rejected') {
            _rejectedRequests.add(request.copyWith(status: newStatus));
            _pendingRequests.removeWhere((r) => r.id == request.id);
            _approvedRequests.removeWhere((r) => r.id == request.id);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status changed to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNotifications() {
    // TODO: Show notification center
  }

  void _createEmployeeID() {
    // TODO: Navigate to create employee ID screen
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.verifiedYellow;
      case 'approved':
        return AppTheme.verifiedGreen;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Phone masking disabled - showing full number
  // Uncomment below if you want to mask phone numbers for privacy
  // String _maskPhoneNumber(String phone) {
  //   if (phone.length <= 4) return phone;
  //   return '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), 'X')}${phone.substring(phone.length - 4)}';
  // }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class VerificationRequest {
  final String id;
  final UserCard userCard;
  final String status;
  final DateTime requestedAt;
  final List<String> documents;

  VerificationRequest({
    required this.id,
    required this.userCard,
    required this.status,
    required this.requestedAt,
    required this.documents,
  });

  VerificationRequest copyWith({
    String? id,
    UserCard? userCard,
    String? status,
    DateTime? requestedAt,
    List<String>? documents,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userCard: userCard ?? this.userCard,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      documents: documents ?? this.documents,
    );
  }
}
