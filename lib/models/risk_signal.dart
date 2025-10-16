/// Model for risk signals and abuse detection
class RiskSignal {
  final String id;
  final String? userId;
  final String? cardId;
  final String type; // rapid_scans, geo_anomaly, device_churn, duplicate_docs
  final double signalScore; // 0.0 to 1.0
  final Map<String, dynamic> details;
  final DateTime triggeredAt;
  final String? tenantId;
  final String? effectiveRole;

  RiskSignal({
    required this.id,
    this.userId,
    this.cardId,
    required this.type,
    required this.signalScore,
    required this.details,
    required this.triggeredAt,
    this.tenantId,
    this.effectiveRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cardId': cardId,
      'type': type,
      'signalScore': signalScore,
      'details': details,
      'triggeredAt': triggeredAt.toIso8601String(),
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
    };
  }

  factory RiskSignal.fromMap(Map<String, dynamic> map, String id) {
    return RiskSignal(
      id: id,
      userId: map['userId'],
      cardId: map['cardId'],
      type: map['type'] ?? '',
      signalScore: (map['signalScore'] ?? 0.0).toDouble(),
      details: map['details'] != null ? Map<String, dynamic>.from(map['details']) : {},
      triggeredAt: DateTime.parse(map['triggeredAt']),
      tenantId: map['tenantId'],
      effectiveRole: map['effectiveRole'],
    );
  }
}

/// Model for risk outcomes and case management
class RiskOutcome {
  final String id;
  final String caseId;
  final String disposition; // approved/rejected/escalated
  final String? reviewerId;
  final DateTime decidedAt;
  final List<String> reasons;
  final String? tenantId;
  final String? effectiveRole;

  RiskOutcome({
    required this.id,
    required this.caseId,
    required this.disposition,
    this.reviewerId,
    required this.decidedAt,
    required this.reasons,
    this.tenantId,
    this.effectiveRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseId': caseId,
      'disposition': disposition,
      'reviewerId': reviewerId,
      'decidedAt': decidedAt.toIso8601String(),
      'reasons': reasons,
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
    };
  }

  factory RiskOutcome.fromMap(Map<String, dynamic> map, String id) {
    return RiskOutcome(
      id: id,
      caseId: map['caseId'] ?? '',
      disposition: map['disposition'] ?? '',
      reviewerId: map['reviewerId'],
      decidedAt: DateTime.parse(map['decidedAt']),
      reasons: List<String>.from(map['reasons'] ?? []),
      tenantId: map['tenantId'],
      effectiveRole: map['effectiveRole'],
    );
  }
}
