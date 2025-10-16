import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_approval_request.dart';
import '../models/user_card.dart';
import '../models/company_details.dart';
import 'notification_service.dart';
import 'company_matching_service.dart';

/// Service for managing company approval requests
/// Handles the workflow when users create cards for existing companies
class CompanyApprovalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create approval request when user creates card for existing company
  static Future<String?> createApprovalRequest({
    required String cardId,
    required String companyId,
    required String companyAdminId,
    required String requesterId,
    required String companyName,
    required String requesterName,
    required String requesterPhone,
    String? designation,
  }) async {
    try {
      final requestDoc = _firestore.collection('company_approval_requests').doc();
      
      final request = CompanyApprovalRequest(
        id: requestDoc.id,
        cardId: cardId,
        companyId: companyId,
        companyAdminId: companyAdminId,
        requesterId: requesterId, // FIXED: This is now the user ID, not card ID
        companyName: companyName,
        requesterName: requesterName,
        requesterPhone: requesterPhone,
        designation: designation,
        status: CompanyApprovalStatus.pending,
        createdAt: DateTime.now(),
      );

      await requestDoc.set(request.toMap());

      // Notify company admin
      await _notifyCompanyAdmin(companyAdminId, request);

      // Log activity
      await _logActivity(
        type: 'company_approval_request_created',
        title: 'New Company Approval Request',
        details: '$requesterName requested approval for $companyName',
        data: request.toMap(),
      );

      print('Company approval request created: ${requestDoc.id}');
      return requestDoc.id;
    } catch (e) {
      print('Error creating approval request: $e');
      return null;
    }
  }

  /// Get pending approval requests for a company (with pagination)
  static Stream<List<CompanyApprovalRequest>> getPendingRequests(
    String companyId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('company_approval_requests')
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: CompanyApprovalStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompanyApprovalRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get all approval requests for a company (with pagination)
  static Stream<List<CompanyApprovalRequest>> getAllRequests(
    String companyId, {
    int limit = 20,
    CompanyApprovalStatus? status,
  }) {
    Query query = _firestore
        .collection('company_approval_requests')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CompanyApprovalRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// Approve a company approval request
  static Future<bool> approveRequest(String requestId) async {
    try {
      // Get the request
      final requestDoc = await _firestore
          .collection('company_approval_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        print('Approval request not found: $requestId');
        return false;
      }

      final request = CompanyApprovalRequest.fromMap(requestDoc.data()!, requestId);

      // Update card to be company-verified
      await _firestore.collection('user_cards').doc(request.cardId).update({
        'isCompanyVerified': true,
        'companyId': request.companyId,
        'verifiedBy': request.companyAdminId,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Update approval request status
      await _firestore.collection('company_approval_requests').doc(requestId).update({
        'status': CompanyApprovalStatus.approved.name,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': request.companyAdminId,
      });

      // Notify requester
      await _notifyRequester(
        request.requesterId,
        'approved',
        request.companyName,
        request.requesterName,
      );

      // Log activity
      await _logActivity(
        type: 'company_approval_request_approved',
        title: 'Company Approval Request Approved',
        details: '${request.requesterName} approved for ${request.companyName}',
        data: {'requestId': requestId, 'cardId': request.cardId},
      );

      print('Company approval request approved: $requestId');
      return true;
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  /// Reject a company approval request
  static Future<bool> rejectRequest(
    String requestId, {
    String? rejectionReason,
  }) async {
    try {
      // Get the request
      final requestDoc = await _firestore
          .collection('company_approval_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        print('Approval request not found: $requestId');
        return false;
      }

      final request = CompanyApprovalRequest.fromMap(requestDoc.data()!, requestId);

      // Deactivate the card
      await _firestore.collection('user_cards').doc(request.cardId).update({
        'isActive': false,
        'rejectionReason': rejectionReason ?? 'Company admin rejected the request',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': request.companyAdminId,
      });

      // Update approval request status
      await _firestore.collection('company_approval_requests').doc(requestId).update({
        'status': CompanyApprovalStatus.rejected.name,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': request.companyAdminId,
        'rejectionReason': rejectionReason,
      });

      // Notify requester
      await _notifyRequester(
        request.requesterId,
        'rejected',
        request.companyName,
        request.requesterName,
        rejectionReason: rejectionReason,
      );

      // Log activity
      await _logActivity(
        type: 'company_approval_request_rejected',
        title: 'Company Approval Request Rejected',
        details: '${request.requesterName} rejected for ${request.companyName}',
        data: {
          'requestId': requestId,
          'cardId': request.cardId,
          'reason': rejectionReason,
        },
      );

      print('Company approval request rejected: $requestId');
      return true;
    } catch (e) {
      print('Error rejecting request: $e');
      return false;
    }
  }

  /// Check if user has pending approval request for a company
  static Future<CompanyApprovalRequest?> getUserPendingRequest(
    String userId,
    String companyId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_approval_requests')
          .where('requesterId', isEqualTo: userId)
          .where('companyId', isEqualTo: companyId)
          .where('status', isEqualTo: CompanyApprovalStatus.pending.name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CompanyApprovalRequest.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }

      return null;
    } catch (e) {
      print('Error getting user pending request: $e');
      return null;
    }
  }

  /// Get all approval requests for a specific user
  static Stream<List<CompanyApprovalRequest>> getUserRequests(String userId) {
    return _firestore
        .collection('company_approval_requests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompanyApprovalRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Check if approval request exists for a specific card
  static Future<CompanyApprovalRequest?> getApprovalRequestByCardId(
    String cardId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_approval_requests')
          .where('cardId', isEqualTo: cardId)
          .where('status', isEqualTo: CompanyApprovalStatus.pending.name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CompanyApprovalRequest.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }

      return null;
    } catch (e) {
      print('Error getting approval request by card ID: $e');
      return null;
    }
  }

  /// Notify company admin about new approval request
  static Future<void> _notifyCompanyAdmin(
    String adminUserId,
    CompanyApprovalRequest request,
  ) async {
    try {
      // Create notification
      await _firestore.collection('notifications').add({
        'userId': adminUserId,
        'type': 'company_approval_request',
        'title': 'New Employee Card Request',
        'message': '${request.requesterName} has created a card for your company "${request.companyName}"',
        'data': {
          'requestId': request.id,
          'cardId': request.cardId,
          'requesterName': request.requesterName,
          'requesterPhone': request.requesterPhone,
          'companyName': request.companyName,
          'designation': request.designation,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'actionRequired': true,
      });

      // Send push notification (if service is available)
      try {
        // TODO: Implement push notification service
        // await NotificationService.sendNotification(
        //   userId: adminUserId,
        //   title: 'New Employee Card Request',
        //   message: '${request.requesterName} wants to join ${request.companyName}',
        //   data: {
        //     'type': 'company_approval_request',
        //     'requestId': request.id,
        //   },
        // );
        print('Push notification would be sent to: $adminUserId');
      } catch (e) {
        print('Push notification failed: $e');
      }

      print('Company admin notified: $adminUserId');
    } catch (e) {
      print('Error notifying company admin: $e');
    }
  }

  /// Notify requester about approval/rejection decision
  static Future<void> _notifyRequester(
    String requesterId,
    String status,
    String companyName,
    String requesterName, {
    String? rejectionReason,
  }) async {
    try {
      String title, message;

      if (status == 'approved') {
        title = 'Company Verification Approved! 🎉';
        message = 'Your card for $companyName has been approved and is now company-verified!';
      } else {
        title = 'Company Verification Rejected ❌';
        message = '$companyName has rejected your card request. Your card is no longer active.';
        if (rejectionReason != null && rejectionReason.isNotEmpty) {
          message += '\n\nReason: $rejectionReason';
        }
      }

      // Create notification
      await _firestore.collection('notifications').add({
        'userId': requesterId,
        'type': 'company_approval_result',
        'title': title,
        'message': message,
        'data': {
          'status': status,
          'companyName': companyName,
          'rejectionReason': rejectionReason,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Send push notification (if service is available)
      try {
        // TODO: Implement push notification service
        // await NotificationService.sendNotification(
        //   userId: requesterId,
        //   title: title,
        //   message: message,
        //   data: {
        //     'type': 'company_approval_result',
        //     'status': status,
        //   },
        // );
        print('Push notification would be sent to: $requesterId');
      } catch (e) {
        print('Push notification failed: $e');
      }

      print('Requester notified: $requesterId');
    } catch (e) {
      print('Error notifying requester: $e');
    }
  }

  /// Log activity
  static Future<void> _logActivity({
    required String type,
    required String title,
    required String details,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('activityLogs').add({
        'type': type,
        'title': title,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// Batch approve multiple requests (for admin efficiency)
  static Future<int> batchApproveRequests(List<String> requestIds) async {
    int successCount = 0;
    
    for (final requestId in requestIds) {
      final success = await approveRequest(requestId);
      if (success) successCount++;
    }

    return successCount;
  }

  /// Batch reject multiple requests (for admin efficiency)
  static Future<int> batchRejectRequests(
    List<String> requestIds, {
    String? rejectionReason,
  }) async {
    int successCount = 0;
    
    for (final requestId in requestIds) {
      final success = await rejectRequest(requestId, rejectionReason: rejectionReason);
      if (success) successCount++;
    }

    return successCount;
  }
}

