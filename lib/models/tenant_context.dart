/// Model for tenant context and role management
class TenantContext {
  final String tenantId;
  final String effectiveRole;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  TenantContext({
    required this.tenantId,
    required this.effectiveRole,
    required this.userId,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory TenantContext.fromMap(Map<String, dynamic> map) {
    return TenantContext(
      tenantId: map['tenantId'] ?? '',
      effectiveRole: map['effectiveRole'] ?? 'user',
      userId: map['userId'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }
}
