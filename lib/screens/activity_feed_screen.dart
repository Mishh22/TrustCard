import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final List<ActivityItem> _activities = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: _activities.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return _buildActivityCard(activity);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your recent card views, verification requests, and QR scans will appear here',
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

  Widget _buildActivityCard(ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Activity Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: _getActivityColor(activity.type),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Activity Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeAgo(activity.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      if (activity.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(activity.status!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            activity.status!.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(activity.status!),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _loadActivities() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser == null) return;

      final snapshot = await _firestore
          .collection('activityLogs')
          .where('userId', isEqualTo: authProvider.currentUser!.id)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        _activities.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          _activities.add(ActivityItem(
            id: doc.id,
            type: _getActivityTypeFromString(data['type'] ?? ''),
            title: data['title'] ?? 'Activity',
            description: data['description'] ?? '',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            status: data['status'],
            data: Map<String, dynamic>.from(data['data'] ?? {}),
          ));
        }
      });
    } catch (e) {
      print('Error loading activities: $e');
      // Fallback to mock data if Firebase fails
      _loadMockActivities();
    }
  }

  void _loadMockActivities() {
    setState(() {
      _activities.addAll([
        ActivityItem(
          id: 'act_1',
          type: ActivityType.cardView,
          title: 'Card Viewed',
          description: 'Your TrustCard was viewed by a customer',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          status: 'completed',
          data: {'viewerId': 'customer_123'},
        ),
        ActivityItem(
          id: 'act_2',
          type: ActivityType.qrScan,
          title: 'QR Code Scanned',
          description: 'You scanned Priya Sharma\'s TrustCard',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          status: 'completed',
          data: {'scannedCardId': 'card_456'},
        ),
        ActivityItem(
          id: 'act_3',
          type: ActivityType.verificationRequest,
          title: 'Verification Request',
          description: 'You requested company verification',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'pending',
          data: {'requestId': 'req_789'},
        ),
        ActivityItem(
          id: 'act_4',
          type: ActivityType.documentUpload,
          title: 'Document Uploaded',
          description: 'Company ID card uploaded for verification',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          status: 'completed',
          data: {'documentType': 'company_id'},
        ),
        ActivityItem(
          id: 'act_5',
          type: ActivityType.peerVerification,
          title: 'Peer Verification',
          description: 'You were verified by 2 colleagues',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: 'completed',
          data: {'colleagueCount': 2},
        ),
        ActivityItem(
          id: 'act_6',
          type: ActivityType.rating,
          title: 'Rating Received',
          description: 'You received a 5-star rating from a customer',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          status: 'completed',
          data: {'rating': 5, 'reviewerId': 'customer_456'},
        ),
        ActivityItem(
          id: 'act_7',
          type: ActivityType.cardCreated,
          title: 'Card Created',
          description: 'Your TrustCard was successfully created',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          status: 'completed',
          data: {'cardId': 'card_123'},
        ),
      ]);
    });
  }

  ActivityType _getActivityTypeFromString(String type) {
    switch (type) {
      case 'cardView':
        return ActivityType.cardView;
      case 'qrScan':
        return ActivityType.qrScan;
      case 'verificationRequest':
        return ActivityType.verificationRequest;
      case 'documentUpload':
        return ActivityType.documentUpload;
      case 'peerVerification':
        return ActivityType.peerVerification;
      case 'rating':
        return ActivityType.rating;
      case 'cardCreated':
        return ActivityType.cardCreated;
      case 'login':
        return ActivityType.login;
      case 'logout':
        return ActivityType.logout;
      case 'company_verification_withdrawal':
        return ActivityType.companyVerificationWithdrawal;
      default:
        return ActivityType.cardView;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Card Views'),
              onTap: () => _filterByType(ActivityType.cardView),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('QR Scans'),
              onTap: () => _filterByType(ActivityType.qrScan),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Verification Requests'),
              onTap: () => _filterByType(ActivityType.verificationRequest),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Document Uploads'),
              onTap: () => _filterByType(ActivityType.documentUpload),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Peer Verification'),
              onTap: () => _filterByType(ActivityType.peerVerification),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Ratings'),
              onTap: () => _filterByType(ActivityType.rating),
            ),
          ],
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

  void _filterByType(ActivityType type) {
    // TODO: Implement filtering
    Navigator.pop(context);
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.cardView:
        return Icons.visibility;
      case ActivityType.qrScan:
        return Icons.qr_code_scanner;
      case ActivityType.verificationRequest:
        return Icons.verified_user;
      case ActivityType.documentUpload:
        return Icons.upload_file;
      case ActivityType.peerVerification:
        return Icons.people;
      case ActivityType.rating:
        return Icons.star;
      case ActivityType.cardCreated:
        return Icons.add_card;
      case ActivityType.login:
        return Icons.login;
      case ActivityType.logout:
        return Icons.logout;
      case ActivityType.companyVerificationWithdrawal:
        return Icons.cancel_outlined;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.cardView:
        return AppTheme.primaryBlue;
      case ActivityType.qrScan:
        return AppTheme.verifiedGreen;
      case ActivityType.verificationRequest:
        return AppTheme.verifiedYellow;
      case ActivityType.documentUpload:
        return AppTheme.verifiedBlue;
      case ActivityType.peerVerification:
        return AppTheme.verifiedGold;
      case ActivityType.rating:
        return Colors.orange;
      case ActivityType.cardCreated:
        return AppTheme.verifiedGreen;
      case ActivityType.login:
        return Colors.green;
      case ActivityType.logout:
        return Colors.red;
      case ActivityType.companyVerificationWithdrawal:
        return Colors.orange;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.verifiedGreen;
      case 'pending':
        return AppTheme.verifiedYellow;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? status;
  final Map<String, dynamic> data;

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.status,
    required this.data,
  });
}

enum ActivityType {
  cardView,
  qrScan,
  verificationRequest,
  documentUpload,
  peerVerification,
  rating,
  cardCreated,
  login,
  logout,
  companyVerificationWithdrawal,
}
