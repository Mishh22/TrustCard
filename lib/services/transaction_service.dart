import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as TransactionModel;

class TransactionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create transaction (future monetization)
  static Future<String> createTransaction({
    required String userId,
    String? cardId,
    String? companyId,
    required String productType,
    required double amount,
    String currency = 'USD',
    double? tax,
    double? discount,
    String? processor,
    String? campaign,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final netAmount = amount - (discount ?? 0.0) + (tax ?? 0.0);
      
      final transaction = TransactionModel.Transaction(
        id: _firestore.collection('transactions').doc().id,
        userId: userId,
        cardId: cardId,
        companyId: companyId,
        productType: productType,
        amount: amount,
        currency: currency,
        tax: tax,
        discount: discount,
        netAmount: netAmount,
        status: 'initiated',
        processor: processor,
        initiatedAt: DateTime.now(),
        campaign: campaign,
        tenantId: tenantId,
        effectiveRole: effectiveRole,
      );

      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());

      return transaction.id;
    } catch (e) {
      print('Error creating transaction: $e');
      return '';
    }
  }

  // Update transaction status
  static Future<void> updateTransactionStatus({
    required String transactionId,
    required String status,
    String? processorRef,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      if (processorRef != null) {
        updates['processorRef'] = processorRef;
      }

      if (status == 'authorized') {
        updates['authorizedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'settled') {
        updates['settledAt'] = DateTime.now().toIso8601String();
      } else if (status == 'refunded') {
        updates['refundedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'charged_back') {
        updates['chargedBackAt'] = DateTime.now().toIso8601String();
      }

      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update(updates);
    } catch (e) {
      print('Error updating transaction status: $e');
    }
  }

  // Get transactions for user
  static Future<List<TransactionModel.Transaction>> getUserTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('initiatedAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user transactions: $e');
      return [];
    }
  }

  // Get transaction metrics
  static Future<Map<String, dynamic>> getTransactionMetrics({
    String? userId,
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('transactions');
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (companyId != null) {
        query = query.where('companyId', isEqualTo: companyId);
      }
      
      if (startDate != null) {
        query = query.where('initiatedAt', isGreaterThan: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('initiatedAt', isLessThan: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final transactions = querySnapshot.docs
          .map((doc) => TransactionModel.Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.netAmount);
      final settledTransactions = transactions.where((t) => t.status == 'settled').toList();
      final settledAmount = settledTransactions.fold(0.0, (sum, t) => sum + t.netAmount);

      return {
        'totalTransactions': transactions.length,
        'totalAmount': totalAmount,
        'settledTransactions': settledTransactions.length,
        'settledAmount': settledAmount,
        'averageTransactionValue': transactions.isNotEmpty ? totalAmount / transactions.length : 0,
        'settlementRate': transactions.isNotEmpty ? (settledTransactions.length / transactions.length) * 100 : 0,
      };
    } catch (e) {
      print('Error getting transaction metrics: $e');
      return {};
    }
  }
}