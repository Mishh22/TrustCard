import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for company verification status
enum CompanyStatus {
  unverified,  // Company exists but no admin verified it yet
  pending,     // Verification request submitted, awaiting approval
  verified,    // Company verified by admin
}

class CompanyDetails {
  final String id;
  final String companyName;
  final String canonicalCompanyName; // Normalized name for matching
  final String businessAddress;
  final String phoneNumber;
  final String email;
  final String contactPerson;
  final String adminUserId; // Empty string if unverified
  final List<String> employees;
  final int employeeCount; // Track count for performance
  final DateTime createdAt;
  final DateTime? verifiedAt; // When company was verified
  final bool isActive;
  final String? gstNumber;
  final String? panNumber;
  final CompanyStatus verificationStatus;

  CompanyDetails({
    required this.id,
    required this.companyName,
    required this.canonicalCompanyName,
    this.businessAddress = '',
    this.phoneNumber = '',
    this.email = '',
    this.contactPerson = '',
    this.adminUserId = '', // Empty for unverified companies
    this.employees = const [],
    int? employeeCount,
    required this.createdAt,
    this.verifiedAt,
    this.isActive = true,
    this.gstNumber,
    this.panNumber,
    this.verificationStatus = CompanyStatus.unverified,
  }) : employeeCount = employeeCount ?? employees.length;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'canonicalCompanyName': canonicalCompanyName,
      'businessAddress': businessAddress,
      'phoneNumber': phoneNumber,
      'email': email,
      'contactPerson': contactPerson,
      'adminUserId': adminUserId,
      'employees': employees,
      'employeeCount': employeeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'isActive': isActive,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'verificationStatus': verificationStatus.name,
    };
  }

  // Create from Firestore document
  factory CompanyDetails.fromMap(Map<String, dynamic> map, String documentId) {
    return CompanyDetails(
      id: documentId,
      companyName: map['companyName'] ?? '',
      canonicalCompanyName: map['canonicalCompanyName'] ?? map['companyName']?.toString().toLowerCase().trim() ?? '',
      businessAddress: map['businessAddress'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      adminUserId: map['adminUserId'] ?? '',
      employees: List<String>.from(map['employees'] ?? []),
      employeeCount: map['employeeCount'] ?? (map['employees'] as List?)?.length ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      verificationStatus: CompanyStatus.values.firstWhere(
        (e) => e.name == map['verificationStatus'],
        orElse: () => CompanyStatus.unverified,
      ),
    );
  }

  // Copy with method for updates
  CompanyDetails copyWith({
    String? id,
    String? companyName,
    String? canonicalCompanyName,
    String? businessAddress,
    String? phoneNumber,
    String? email,
    String? contactPerson,
    String? adminUserId,
    List<String>? employees,
    int? employeeCount,
    DateTime? createdAt,
    DateTime? verifiedAt,
    bool? isActive,
    String? gstNumber,
    String? panNumber,
    CompanyStatus? verificationStatus,
  }) {
    return CompanyDetails(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      canonicalCompanyName: canonicalCompanyName ?? this.canonicalCompanyName,
      businessAddress: businessAddress ?? this.businessAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      contactPerson: contactPerson ?? this.contactPerson,
      adminUserId: adminUserId ?? this.adminUserId,
      employees: employees ?? this.employees,
      employeeCount: employeeCount ?? this.employeeCount,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      isActive: isActive ?? this.isActive,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
  
  // Helper methods
  bool get isVerified => verificationStatus == CompanyStatus.verified;
  bool get isUnverified => verificationStatus == CompanyStatus.unverified;
  bool get isPending => verificationStatus == CompanyStatus.pending;
  bool get hasAdmin => adminUserId.isNotEmpty;
}
