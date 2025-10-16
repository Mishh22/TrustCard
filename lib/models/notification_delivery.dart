/// Model for notification delivery tracking
class NotificationDelivery {
  final String id;
  final String notificationId;
  final String userId;
  final String type; // scan_notification, system_notification, marketing
  final String channel; // push, email, sms
  final DateTime sendAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;
  final String? failureCode;
  final String? providerMessageId;
  final int retryCount;
  final String? tenantId;
  final String? effectiveRole;

  NotificationDelivery({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.channel,
    required this.sendAt,
    this.deliveredAt,
    this.openedAt,
    this.failureCode,
    this.providerMessageId,
    this.retryCount = 0,
    this.tenantId,
    this.effectiveRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notificationId': notificationId,
      'userId': userId,
      'type': type,
      'channel': channel,
      'sendAt': sendAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'openedAt': openedAt?.toIso8601String(),
      'failureCode': failureCode,
      'providerMessageId': providerMessageId,
      'retryCount': retryCount,
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
    };
  }

  factory NotificationDelivery.fromMap(Map<String, dynamic> map, String id) {
    return NotificationDelivery(
      id: id,
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      channel: map['channel'] ?? '',
      sendAt: DateTime.parse(map['sendAt']),
      deliveredAt: map['deliveredAt'] != null ? DateTime.parse(map['deliveredAt']) : null,
      openedAt: map['openedAt'] != null ? DateTime.parse(map['openedAt']) : null,
      failureCode: map['failureCode'],
      providerMessageId: map['providerMessageId'],
      retryCount: map['retryCount'] ?? 0,
      tenantId: map['tenantId'],
      effectiveRole: map['effectiveRole'],
    );
  }
}
