enum VerificationRequestStatus {
  pending,
  accepted,
  declined,
}

class VerificationRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String colleaguePhone;
  final String colleagueName;
  final VerificationRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? response;

  VerificationRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.colleaguePhone,
    required this.colleagueName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.response,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'colleaguePhone': colleaguePhone,
      'colleagueName': colleagueName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'response': response,
    };
  }

  factory VerificationRequest.fromMap(Map<String, dynamic> map, String id) {
    return VerificationRequest(
      id: id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      colleaguePhone: map['colleaguePhone'] ?? '',
      colleagueName: map['colleagueName'] ?? '',
      status: VerificationRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VerificationRequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      respondedAt: map['respondedAt'] != null 
          ? DateTime.parse(map['respondedAt']) 
          : null,
      response: map['response'],
    );
  }

  VerificationRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? colleaguePhone,
    String? colleagueName,
    VerificationRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? response,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      colleaguePhone: colleaguePhone ?? this.colleaguePhone,
      colleagueName: colleagueName ?? this.colleagueName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      response: response ?? this.response,
    );
  }
}
