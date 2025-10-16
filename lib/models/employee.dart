import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String companyId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String designation;
  final String? employeeId;
  final String? profilePhoto;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime? invitationSentAt;
  final String? invitationStatus;

  Employee({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.designation,
    this.employeeId,
    this.profilePhoto,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.invitationSentAt,
    this.invitationStatus,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'designation': designation,
      'employeeId': employeeId,
      'profilePhoto': profilePhoto,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
      'invitationSentAt': invitationSentAt != null ? Timestamp.fromDate(invitationSentAt!) : null,
      'invitationStatus': invitationStatus,
    };
  }

  // Create from Firestore document
  factory Employee.fromMap(Map<String, dynamic> map, String documentId) {
    return Employee(
      id: documentId,
      companyId: map['companyId'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      designation: map['designation'] ?? '',
      employeeId: map['employeeId'],
      profilePhoto: map['profilePhoto'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: map['expiresAt'] != null ? (map['expiresAt'] as Timestamp).toDate() : null,
      isActive: map['isActive'] ?? true,
      invitationSentAt: map['invitationSentAt'] != null ? (map['invitationSentAt'] as Timestamp).toDate() : null,
      invitationStatus: map['invitationStatus'],
    );
  }

  // Copy with method for updates
  Employee copyWith({
    String? id,
    String? companyId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? designation,
    String? employeeId,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? invitationSentAt,
    String? invitationStatus,
  }) {
    return Employee(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      employeeId: employeeId ?? this.employeeId,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      invitationSentAt: invitationSentAt ?? this.invitationSentAt,
      invitationStatus: invitationStatus ?? this.invitationStatus,
    );
  }
}

