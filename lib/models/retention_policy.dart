class RetentionPolicy {
  final String id;
  final String collection;
  final String piiLevel; // 'PII', 'SPI', 'Public'
  final int ttlDays;
  final String? archivalBucket;
  final String eraseStrategy; // 'hard', 'tombstone'
  final DateTime lastEvaluatedAt;
  final bool isActive;

  RetentionPolicy({
    required this.id,
    required this.collection,
    required this.piiLevel,
    required this.ttlDays,
    this.archivalBucket,
    required this.eraseStrategy,
    required this.lastEvaluatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection': collection,
      'piiLevel': piiLevel,
      'ttlDays': ttlDays,
      'archivalBucket': archivalBucket,
      'eraseStrategy': eraseStrategy,
      'lastEvaluatedAt': lastEvaluatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory RetentionPolicy.fromMap(Map<String, dynamic> map, String id) {
    return RetentionPolicy(
      id: id,
      collection: map['collection'] ?? '',
      piiLevel: map['piiLevel'] ?? '',
      ttlDays: map['ttlDays'] ?? 0,
      archivalBucket: map['archivalBucket'],
      eraseStrategy: map['eraseStrategy'] ?? '',
      lastEvaluatedAt: DateTime.parse(map['lastEvaluatedAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}
