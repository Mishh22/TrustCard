/// Model for employment history tracking
class EmploymentEvent {
  final String id;
  final String userId;
  final String companyId;
  final String designation;
  final String action; // joined/left/changed_role
  final DateTime occurredAt;
  final String? previousDesignation;
  final String? previousCompanyId;
  final Map<String, dynamic>? metadata;
  final String? tenantId;
  final String? effectiveRole;

  EmploymentEvent({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.designation,
    required this.action,
    required this.occurredAt,
    this.previousDesignation,
    this.previousCompanyId,
    this.metadata,
    this.tenantId,
    this.effectiveRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'designation': designation,
      'action': action,
      'occurredAt': occurredAt.toIso8601String(),
      'previousDesignation': previousDesignation,
      'previousCompanyId': previousCompanyId,
      'metadata': metadata,
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
    };
  }

  factory EmploymentEvent.fromMap(Map<String, dynamic> map, String id) {
    return EmploymentEvent(
      id: id,
      userId: map['userId'] ?? '',
      companyId: map['companyId'] ?? '',
      designation: map['designation'] ?? '',
      action: map['action'] ?? '',
      occurredAt: DateTime.parse(map['occurredAt']),
      previousDesignation: map['previousDesignation'],
      previousCompanyId: map['previousCompanyId'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      tenantId: map['tenantId'],
      effectiveRole: map['effectiveRole'],
    );
  }
}
