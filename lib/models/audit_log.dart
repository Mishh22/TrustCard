class AuditLog {
  final String id;
  final String actorUserId;
  final String role;
  final String action; // 'read_profile', 'export_scans', 'verify_company'
  final String resourcePath;
  final String? beforeHash;
  final String? afterHash;
  final String? reasonCode;
  final String? ipAddress;
  final String? deviceId;
  final DateTime timestamp;
  final String outcome; // 'success', 'failure', 'error'

  AuditLog({
    required this.id,
    required this.actorUserId,
    required this.role,
    required this.action,
    required this.resourcePath,
    this.beforeHash,
    this.afterHash,
    this.reasonCode,
    this.ipAddress,
    this.deviceId,
    required this.timestamp,
    required this.outcome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actorUserId': actorUserId,
      'role': role,
      'action': action,
      'resourcePath': resourcePath,
      'beforeHash': beforeHash,
      'afterHash': afterHash,
      'reasonCode': reasonCode,
      'ipAddress': ipAddress,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'outcome': outcome,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map, String id) {
    return AuditLog(
      id: id,
      actorUserId: map['actorUserId'] ?? '',
      role: map['role'] ?? '',
      action: map['action'] ?? '',
      resourcePath: map['resourcePath'] ?? '',
      beforeHash: map['beforeHash'],
      afterHash: map['afterHash'],
      reasonCode: map['reasonCode'],
      ipAddress: map['ipAddress'],
      deviceId: map['deviceId'],
      timestamp: DateTime.parse(map['timestamp']),
      outcome: map['outcome'] ?? '',
    );
  }
}
