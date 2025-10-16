import 'package:cloud_firestore/cloud_firestore.dart';

enum CompanyVerificationStatus {
  pending,
  approved,
  rejected,
  withdrawn,
}

class CompanyVerificationRequest {
  final String id;
  final String userId;
  final String companyName;
  final String businessAddress;
  final String phoneNumber;
  final String email;
  final String contactPerson;
  final String businessPhotoUrl;
  final String? gstNumber;
  final String? panNumber;
  final String? gstCertificateUrl;
  final String? panCertificateUrl;
  final CompanyVerificationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? withdrawnAt;
  final String? withdrawnBy;

  CompanyVerificationRequest({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.businessAddress,
    required this.phoneNumber,
    required this.email,
    required this.contactPerson,
    required this.businessPhotoUrl,
    this.gstNumber,
    this.panNumber,
    this.gstCertificateUrl,
    this.panCertificateUrl,
    this.status = CompanyVerificationStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.reviewedBy,
    this.withdrawnAt,
    this.withdrawnBy,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'businessAddress': businessAddress,
      'phoneNumber': phoneNumber,
      'email': email,
      'contactPerson': contactPerson,
      'businessPhotoUrl': businessPhotoUrl,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'gstCertificateUrl': gstCertificateUrl,
      'panCertificateUrl': panCertificateUrl,
      'status': status.name,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'rejectionReason': rejectionReason,
      'reviewedBy': reviewedBy,
      'withdrawnAt': withdrawnAt != null ? Timestamp.fromDate(withdrawnAt!) : null,
      'withdrawnBy': withdrawnBy,
    };
  }

  // Create from Firestore document
  factory CompanyVerificationRequest.fromMap(Map<String, dynamic> map, String documentId) {
    return CompanyVerificationRequest(
      id: documentId,
      userId: map['userId'] ?? '',
      companyName: map['companyName'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      businessPhotoUrl: map['businessPhotoUrl'] ?? '',
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      gstCertificateUrl: map['gstCertificateUrl'],
      panCertificateUrl: map['panCertificateUrl'],
      status: CompanyVerificationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CompanyVerificationStatus.pending,
      ),
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      reviewedAt: map['reviewedAt'] != null ? (map['reviewedAt'] as Timestamp).toDate() : null,
      rejectionReason: map['rejectionReason'],
      reviewedBy: map['reviewedBy'],
      withdrawnAt: map['withdrawnAt'] != null ? (map['withdrawnAt'] as Timestamp).toDate() : null,
      withdrawnBy: map['withdrawnBy'],
    );
  }

  // Copy with method for updates
  CompanyVerificationRequest copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? businessAddress,
    String? phoneNumber,
    String? email,
    String? contactPerson,
    String? businessPhotoUrl,
    String? gstNumber,
    String? panNumber,
    String? gstCertificateUrl,
    String? panCertificateUrl,
    CompanyVerificationStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? reviewedBy,
    DateTime? withdrawnAt,
    String? withdrawnBy,
  }) {
    return CompanyVerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      businessAddress: businessAddress ?? this.businessAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      contactPerson: contactPerson ?? this.contactPerson,
      businessPhotoUrl: businessPhotoUrl ?? this.businessPhotoUrl,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      gstCertificateUrl: gstCertificateUrl ?? this.gstCertificateUrl,
      panCertificateUrl: panCertificateUrl ?? this.panCertificateUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      withdrawnBy: withdrawnBy ?? this.withdrawnBy,
    );
  }
}
