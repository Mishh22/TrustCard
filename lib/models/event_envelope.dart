import 'package:uuid/uuid.dart';

/// Standardized event envelope for all events
class EventEnvelope {
  final String eventId; // UUID v7
  final String schemaVersion;
  final DateTime occurredAt;
  final DateTime receivedAt;
  final String source; // ios/android/web/server
  final String? idempotencyKey;
  final String? traceId;
  final String tenantId;
  final String effectiveRole;
  final Map<String, dynamic>? metadata;

  EventEnvelope({
    required this.eventId,
    required this.schemaVersion,
    required this.occurredAt,
    required this.receivedAt,
    required this.source,
    this.idempotencyKey,
    this.traceId,
    required this.tenantId,
    required this.effectiveRole,
    this.metadata,
  });

  /// Create new event envelope with auto-generated UUID v7
  factory EventEnvelope.create({
    required String source,
    required String tenantId,
    required String effectiveRole,
    String? idempotencyKey,
    String? traceId,
    Map<String, dynamic>? metadata,
  }) {
    return EventEnvelope(
      eventId: const Uuid().v7(),
      schemaVersion: '1.0',
      occurredAt: DateTime.now(),
      receivedAt: DateTime.now(),
      source: source,
      idempotencyKey: idempotencyKey,
      traceId: traceId,
      tenantId: tenantId,
      effectiveRole: effectiveRole,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'schemaVersion': schemaVersion,
      'occurredAt': occurredAt.toIso8601String(),
      'receivedAt': receivedAt.toIso8601String(),
      'source': source,
      'idempotencyKey': idempotencyKey,
      'traceId': traceId,
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
      'metadata': metadata,
    };
  }

  factory EventEnvelope.fromMap(Map<String, dynamic> map) {
    return EventEnvelope(
      eventId: map['eventId'] ?? '',
      schemaVersion: map['schemaVersion'] ?? '1.0',
      occurredAt: DateTime.parse(map['occurredAt']),
      receivedAt: DateTime.parse(map['receivedAt']),
      source: map['source'] ?? '',
      idempotencyKey: map['idempotencyKey'],
      traceId: map['traceId'],
      tenantId: map['tenantId'] ?? '',
      effectiveRole: map['effectiveRole'] ?? 'user',
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }
}
