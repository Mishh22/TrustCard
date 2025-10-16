class ConsentRecord {
  final String id;
  final String userId;
  final List<String> scopes; // ['analytics', 'marketing', 'personalization']
  final String policyVersion;
  final String jurisdiction;
  final DateTime grantedAt;
  final DateTime? revokedAt;
  final String method; // 'in-app', 'web'
  final String? ipAddress;
  final String? deviceId;
  final bool isActive;

  ConsentRecord({
    required this.id,
    required this.userId,
    required this.scopes,
    required this.policyVersion,
    required this.jurisdiction,
    required this.grantedAt,
    this.revokedAt,
    required this.method,
    this.ipAddress,
    this.deviceId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'scopes': scopes,
      'policyVersion': policyVersion,
      'jurisdiction': jurisdiction,
      'grantedAt': grantedAt.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
      'method': method,
      'ipAddress': ipAddress,
      'deviceId': deviceId,
      'isActive': isActive,
    };
  }

  factory ConsentRecord.fromMap(Map<String, dynamic> map, String id) {
    return ConsentRecord(
      id: id,
      userId: map['userId'] ?? '',
      scopes: List<String>.from(map['scopes'] ?? []),
      policyVersion: map['policyVersion'] ?? '',
      jurisdiction: map['jurisdiction'] ?? '',
      grantedAt: DateTime.parse(map['grantedAt']),
      revokedAt: map['revokedAt'] != null ? DateTime.parse(map['revokedAt']) : null,
      method: map['method'] ?? '',
      ipAddress: map['ipAddress'],
      deviceId: map['deviceId'],
      isActive: map['isActive'] ?? true,
    );
  }
}
