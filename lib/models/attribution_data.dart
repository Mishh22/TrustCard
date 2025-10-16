class AttributionData {
  final String id;
  final String userId;
  final String? source; // 'google', 'facebook', 'organic', 'direct'
  final String? medium; // 'cpc', 'organic', 'social', 'email'
  final String? campaign;
  final String? adGroup;
  final String? channel; // 'mobile', 'web', 'app'
  final DateTime firstTouchAt;
  final DateTime? lastTouchAt;
  final DateTime? firstSessionAt;
  final String? invitedBy;
  final String? inviteId;

  AttributionData({
    required this.id,
    required this.userId,
    this.source,
    this.medium,
    this.campaign,
    this.adGroup,
    this.channel,
    required this.firstTouchAt,
    this.lastTouchAt,
    this.firstSessionAt,
    this.invitedBy,
    this.inviteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'source': source,
      'medium': medium,
      'campaign': campaign,
      'adGroup': adGroup,
      'channel': channel,
      'firstTouchAt': firstTouchAt.toIso8601String(),
      'lastTouchAt': lastTouchAt?.toIso8601String(),
      'firstSessionAt': firstSessionAt?.toIso8601String(),
      'invitedBy': invitedBy,
      'inviteId': inviteId,
    };
  }

  factory AttributionData.fromMap(Map<String, dynamic> map, String id) {
    return AttributionData(
      id: id,
      userId: map['userId'] ?? '',
      source: map['source'],
      medium: map['medium'],
      campaign: map['campaign'],
      adGroup: map['adGroup'],
      channel: map['channel'],
      firstTouchAt: DateTime.parse(map['firstTouchAt']),
      lastTouchAt: map['lastTouchAt'] != null ? DateTime.parse(map['lastTouchAt']) : null,
      firstSessionAt: map['firstSessionAt'] != null ? DateTime.parse(map['firstSessionAt']) : null,
      invitedBy: map['invitedBy'],
      inviteId: map['inviteId'],
    );
  }
}
