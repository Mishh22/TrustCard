class SessionData {
  final String id;
  final String userId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final String? deviceId;
  final String? appVersion;
  final String? networkType;
  final String? screen;
  final int? durationSeconds;
  final bool isActive;

  SessionData({
    required this.id,
    required this.userId,
    required this.sessionStart,
    this.sessionEnd,
    this.deviceId,
    this.appVersion,
    this.networkType,
    this.screen,
    this.durationSeconds,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'sessionStart': sessionStart.toIso8601String(),
      'sessionEnd': sessionEnd?.toIso8601String(),
      'deviceId': deviceId,
      'appVersion': appVersion,
      'networkType': networkType,
      'screen': screen,
      'durationSeconds': durationSeconds,
      'isActive': isActive,
    };
  }

  factory SessionData.fromMap(Map<String, dynamic> map, String id) {
    return SessionData(
      id: id,
      userId: map['userId'] ?? '',
      sessionStart: DateTime.parse(map['sessionStart']),
      sessionEnd: map['sessionEnd'] != null ? DateTime.parse(map['sessionEnd']) : null,
      deviceId: map['deviceId'],
      appVersion: map['appVersion'],
      networkType: map['networkType'],
      screen: map['screen'],
      durationSeconds: map['durationSeconds'],
      isActive: map['isActive'] ?? true,
    );
  }
}
