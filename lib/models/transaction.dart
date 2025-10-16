/// Model for transaction tracking (future monetization)
class Transaction {
  final String id;
  final String userId;
  final String? cardId;
  final String? companyId;
  final String productType; // subscription, premium_features, analytics
  final double amount;
  final String currency;
  final double? tax;
  final double? discount;
  final double netAmount;
  final String status; // initiated, authorized, settled, refunded, charged_back
  final String? processor; // stripe, razorpay, payu
  final String? processorRef;
  final DateTime initiatedAt;
  final DateTime? authorizedAt;
  final DateTime? settledAt;
  final DateTime? refundedAt;
  final DateTime? chargedBackAt;
  final String? campaign; // For CAC/LTV analysis
  final String? tenantId;
  final String? effectiveRole;

  Transaction({
    required this.id,
    required this.userId,
    this.cardId,
    this.companyId,
    required this.productType,
    required this.amount,
    required this.currency,
    this.tax,
    this.discount,
    required this.netAmount,
    required this.status,
    this.processor,
    this.processorRef,
    required this.initiatedAt,
    this.authorizedAt,
    this.settledAt,
    this.refundedAt,
    this.chargedBackAt,
    this.campaign,
    this.tenantId,
    this.effectiveRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cardId': cardId,
      'companyId': companyId,
      'productType': productType,
      'amount': amount,
      'currency': currency,
      'tax': tax,
      'discount': discount,
      'netAmount': netAmount,
      'status': status,
      'processor': processor,
      'processorRef': processorRef,
      'initiatedAt': initiatedAt.toIso8601String(),
      'authorizedAt': authorizedAt?.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'chargedBackAt': chargedBackAt?.toIso8601String(),
      'campaign': campaign,
      'tenantId': tenantId,
      'effectiveRole': effectiveRole,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      userId: map['userId'] ?? '',
      cardId: map['cardId'],
      companyId: map['companyId'],
      productType: map['productType'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      tax: map['tax']?.toDouble(),
      discount: map['discount']?.toDouble(),
      netAmount: (map['netAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? '',
      processor: map['processor'],
      processorRef: map['processorRef'],
      initiatedAt: DateTime.parse(map['initiatedAt']),
      authorizedAt: map['authorizedAt'] != null ? DateTime.parse(map['authorizedAt']) : null,
      settledAt: map['settledAt'] != null ? DateTime.parse(map['settledAt']) : null,
      refundedAt: map['refundedAt'] != null ? DateTime.parse(map['refundedAt']) : null,
      chargedBackAt: map['chargedBackAt'] != null ? DateTime.parse(map['chargedBackAt']) : null,
      campaign: map['campaign'],
      tenantId: map['tenantId'],
      effectiveRole: map['effectiveRole'],
    );
  }
}
