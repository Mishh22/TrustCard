import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../services/scan_notification_service.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.getCurrentUser();
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => _markAllAsRead(currentUser.uid),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _clearAllNotifications(currentUser.uid),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ScanNotificationService.getScanNotificationsStream(currentUser.uid),
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
                  Text('Error loading notifications: ${snapshot.error}'),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          final unreadCount = notifications.where((n) => n['isRead'] == false).length;

          return Column(
            children: [
              // Notification Stats
              _buildNotificationStats(notifications.length, unreadCount),
              
              // Notification List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              ),
            ],
          );
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
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll receive notifications about verification requests and updates',
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

  Widget _buildNotificationStats(int totalCount, int unreadCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Center',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated with card scans and alerts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$unreadCount Unread',
              style: const TextStyle(
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

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] ?? false;
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final createdAt = notification['createdAt'] as Timestamp?;
    final timestamp = createdAt?.toDate() ?? DateTime.now();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              _formatTimeAgo(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) async {
    final isRead = notification['isRead'] ?? false;
    final notificationId = notification['id'];
    
    if (!isRead && notificationId != null) {
      await ScanNotificationService.markAsRead(notificationId);
    }

    // Show notification details
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final data = notification['data'] as Map<String, dynamic>?;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (data != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (data['scannerName'] != null)
                Text('Scanner: ${data['scannerName']}'),
              if (data['scannerCompany'] != null)
                Text('Company: ${data['scannerCompany']}'),
              if (data['location'] != null)
                Text('Location: ${data['location']}'),
            ],
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

  void _markAllAsRead(String userId) async {
    await ScanNotificationService.markAllAsRead(userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppTheme.verifiedGreen,
        ),
      );
    }
  }

  void _clearAllNotifications(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ScanNotificationService.deleteAllNotifications(userId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    backgroundColor: AppTheme.verifiedGreen,
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
