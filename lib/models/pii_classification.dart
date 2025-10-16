class PIIClassification {
  final String id;
  final String collection;
  final String field;
  final String classification; // 'PII', 'SPI', 'Public'
  final String encryption; // 'KMS', 'none'
  final String maskPolicy;
  final bool isActive;

  PIIClassification({
    required this.id,
    required this.collection,
    required this.field,
    required this.classification,
    required this.encryption,
    required this.maskPolicy,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection': collection,
      'field': field,
      'classification': classification,
      'encryption': encryption,
      'maskPolicy': maskPolicy,
      'isActive': isActive,
    };
  }

  factory PIIClassification.fromMap(Map<String, dynamic> map, String id) {
    return PIIClassification(
      id: id,
      collection: map['collection'] ?? '',
      field: map['field'] ?? '',
      classification: map['classification'] ?? '',
      encryption: map['encryption'] ?? '',
      maskPolicy: map['maskPolicy'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
