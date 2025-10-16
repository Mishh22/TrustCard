import 'package:flutter/foundation.dart';
import '../models/user_card.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  int _unreadCount = 0;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Add a new notification
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Simulate receiving a verification request notification
  void notifyVerificationRequest(UserCard userCard) {
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.verificationRequest,
      title: 'New Verification Request',
      message: '${userCard.fullName} is requesting company verification',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'userCardId': userCard.id,
        'userName': userCard.fullName,
        'companyName': userCard.companyName,
        'designation': userCard.designation,
      },
    );
    
    addNotification(notification);
    
    // In a real app, this would also send:
    // - Push notification to company admin
    // - Email notification
    // - SMS alert (if configured)
  }

  // Simulate receiving an impersonation alert
  void notifyImpersonationAlert(UserCard userCard, String reportedBy) {
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.impersonationAlert,
      title: 'Impersonation Alert',
      message: 'Someone reported ${userCard.fullName} for impersonation',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'userCardId': userCard.id,
        'userName': userCard.fullName,
        'reportedBy': reportedBy,
      },
    );
    
    addNotification(notification);
  }

  // Simulate receiving a document verification update
  void notifyDocumentVerification(UserCard userCard, bool approved) {
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.documentVerification,
      title: approved ? 'Document Approved' : 'Document Rejected',
      message: '${userCard.fullName}\'s documents have been ${approved ? 'approved' : 'rejected'}',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'userCardId': userCard.id,
        'userName': userCard.fullName,
        'approved': approved,
      },
    );
    
    addNotification(notification);
  }

  // Simulate receiving a peer verification update
  void notifyPeerVerification(UserCard userCard, int colleagueCount) {
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.peerVerification,
      title: 'Peer Verification Complete',
      message: '${userCard.fullName} has been verified by $colleagueCount colleagues',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'userCardId': userCard.id,
        'userName': userCard.fullName,
        'colleagueCount': colleagueCount,
      },
    );
    
    addNotification(notification);
  }

  // Simulate receiving a company verification request
  void notifyCompanyVerificationRequest(String companyName, int requestCount) {
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.companyVerificationRequest,
      title: 'Company Verification Request',
      message: '$requestCount employees from $companyName are requesting verification',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'companyName': companyName,
        'requestCount': requestCount,
      },
    );
    
    addNotification(notification);
  }

  // NEW: Notify when card is scanned
  void notifyCardScanned(String scannerName, String? scannerCompany) {
    final companyText = scannerCompany != null && scannerCompany.isNotEmpty
        ? ' from $scannerCompany'
        : '';
    
    final notification = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.cardScanned,
      title: 'Your Card Was Scanned',
      message: '$scannerName$companyText scanned your card',
      timestamp: DateTime.now(),
      isRead: false,
      data: {
        'scannerName': scannerName,
        'scannerCompany': scannerCompany,
      },
    );
    
    addNotification(notification);
  }

  // Get notifications by type
  List<NotificationItem> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationItem> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get recent notifications (last 7 days)
  List<NotificationItem> getRecentNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.data,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  verificationRequest,
  impersonationAlert,
  documentVerification,
  peerVerification,
  companyVerificationRequest,
  systemUpdate,
  general,
  cardScanned, // NEW: Card scan notification
}

// Mock notification data for testing
class MockNotificationService {
  static List<NotificationItem> getMockNotifications() {
    return [
      NotificationItem(
        id: 'notif_1',
        type: NotificationType.verificationRequest,
        title: 'New Verification Request',
        message: 'Rahul Kumar is requesting company verification',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        data: {
          'userCardId': 'card_1',
          'userName': 'Rahul Kumar',
          'companyName': 'Company 1 Pvt Ltd',
          'designation': 'Delivery Partner',
        },
      ),
      NotificationItem(
        id: 'notif_2',
        type: NotificationType.impersonationAlert,
        title: 'Impersonation Alert',
        message: 'Someone reported Priya Sharma for impersonation',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        data: {
          'userCardId': 'card_2',
          'userName': 'Priya Sharma',
          'reportedBy': 'Customer_123',
        },
      ),
      NotificationItem(
        id: 'notif_3',
        type: NotificationType.documentVerification,
        title: 'Document Approved',
        message: 'Amit Singh\'s documents have been approved',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
        data: {
          'userCardId': 'card_3',
          'userName': 'Amit Singh',
          'approved': true,
        },
      ),
      NotificationItem(
        id: 'notif_4',
        type: NotificationType.peerVerification,
        title: 'Peer Verification Complete',
        message: 'Suresh Kumar has been verified by 3 colleagues',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        data: {
          'userCardId': 'card_4',
          'userName': 'Suresh Kumar',
          'colleagueCount': 3,
        },
      ),
      NotificationItem(
        id: 'notif_5',
        type: NotificationType.companyVerificationRequest,
        title: 'Company Verification Request',
        message: '5 employees from Zomato are requesting verification',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        data: {
          'companyName': 'Zomato',
          'requestCount': 5,
        },
      ),
    ];
  }
}
