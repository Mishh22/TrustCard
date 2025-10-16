class ErrorEvent {
  final String id;
  final String? userId;
  final String platform;
  final String appVersion;
  final String screen;
  final String action;
  final String errorCode;
  final String stackHash;
  final DateTime occurredAt;
  final String? correlatedEventId;

  ErrorEvent({
    required this.id,
    this.userId,
    required this.platform,
    required this.appVersion,
    required this.screen,
    required this.action,
    required this.errorCode,
    required this.stackHash,
    required this.occurredAt,
    this.correlatedEventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'platform': platform,
      'appVersion': appVersion,
      'screen': screen,
      'action': action,
      'errorCode': errorCode,
      'stackHash': stackHash,
      'occurredAt': occurredAt.toIso8601String(),
      'correlatedEventId': correlatedEventId,
    };
  }

  factory ErrorEvent.fromMap(Map<String, dynamic> map, String id) {
    return ErrorEvent(
      id: id,
      userId: map['userId'],
      platform: map['platform'] ?? '',
      appVersion: map['appVersion'] ?? '',
      screen: map['screen'] ?? '',
      action: map['action'] ?? '',
      errorCode: map['errorCode'] ?? '',
      stackHash: map['stackHash'] ?? '',
      occurredAt: DateTime.parse(map['occurredAt']),
      correlatedEventId: map['correlatedEventId'],
    );
  }
}
