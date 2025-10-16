import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for company approval requests
/// When a user creates a card for an existing verified company,
/// an approval request is created for the company admin to review
class CompanyApprovalRequest {
  final String id;
  final String cardId;
  final String companyId;
  final String companyAdminId;
  final String requesterId; // User ID of the person who created the card
  final String companyName;
  final String requesterName;
  final String requesterPhone;
  final String? designation;
  final CompanyApprovalStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  CompanyApprovalRequest({
    required this.id,
    required this.cardId,
    required this.companyId,
    required this.companyAdminId,
    required this.requesterId,
    required this.companyName,
    required this.requesterName,
    required this.requesterPhone,
    this.designation,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'companyId': companyId,
      'companyAdminId': companyAdminId,
      'requesterId': requesterId,
      'companyName': companyName,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'designation': designation,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }

  factory CompanyApprovalRequest.fromMap(Map<String, dynamic> map, String id) {
    return CompanyApprovalRequest(
      id: id,
      cardId: map['cardId'] ?? '',
      companyId: map['companyId'] ?? '',
      companyAdminId: map['companyAdminId'] ?? '',
      requesterId: map['requesterId'] ?? '',
      companyName: map['companyName'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'] ?? '',
      designation: map['designation'],
      status: CompanyApprovalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CompanyApprovalStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: map['reviewedBy'],
      rejectionReason: map['rejectionReason'],
    );
  }

  CompanyApprovalRequest copyWith({
    String? id,
    String? cardId,
    String? companyId,
    String? companyAdminId,
    String? requesterId,
    String? companyName,
    String? requesterName,
    String? requesterPhone,
    String? designation,
    CompanyApprovalStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return CompanyApprovalRequest(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      companyId: companyId ?? this.companyId,
      companyAdminId: companyAdminId ?? this.companyAdminId,
      requesterId: requesterId ?? this.requesterId,
      companyName: companyName ?? this.companyName,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      designation: designation ?? this.designation,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

enum CompanyApprovalStatus {
  pending,
  approved,
  rejected,
}

