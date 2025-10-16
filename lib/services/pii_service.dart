import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pii_classification.dart';

class PIIService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Classify field as PII
  static Future<void> classifyField({
    required String collection,
    required String field,
    required String classification,
    required String encryption,
    required String maskPolicy,
  }) async {
    try {
      final piiClassification = PIIClassification(
        id: _firestore.collection('pii_catalog').doc().id,
        collection: collection,
        field: field,
        classification: classification,
        encryption: encryption,
        maskPolicy: maskPolicy,
      );

      await _firestore
          .collection('pii_catalog')
          .doc(piiClassification.id)
          .set(piiClassification.toMap());
    } catch (e) {
      print('Error classifying PII field: $e');
    }
  }

  // Get classification for field
  static Future<PIIClassification?> getFieldClassification({
    required String collection,
    required String field,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('pii_catalog')
          .where('collection', isEqualTo: collection)
          .where('field', isEqualTo: field)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PIIClassification.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting field classification: $e');
      return null;
    }
  }

  // Check if field is PII
  static Future<bool> isPII({
    required String collection,
    required String field,
  }) async {
    try {
      final classification = await getFieldClassification(
        collection: collection,
        field: field,
      );
      return classification?.classification == 'PII';
    } catch (e) {
      print('Error checking PII status: $e');
      return false;
    }
  }

  // Get all PII fields for collection
  static Future<List<PIIClassification>> getPIIFields(String collection) async {
    try {
      final querySnapshot = await _firestore
          .collection('pii_catalog')
          .where('collection', isEqualTo: collection)
          .where('classification', isEqualTo: 'PII')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PIIClassification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting PII fields: $e');
      return [];
    }
  }

  // Mask PII data for non-privileged access
  static String maskPII(String data, String maskPolicy) {
    switch (maskPolicy) {
      case 'full':
        return '*' * data.length;
      case 'partial':
        if (data.length <= 4) return '*' * data.length;
        return data.substring(0, 2) + '*' * (data.length - 4) + data.substring(data.length - 2);
      case 'email':
        final parts = data.split('@');
        if (parts.length == 2) {
          return '${parts[0][0]}***@${parts[1]}';
        }
        return data;
      case 'phone':
        if (data.length >= 10) {
          return '${data.substring(0, 3)}***${data.substring(data.length - 4)}';
        }
        return data;
      default:
        return data;
    }
  }

  // Get all classifications
  static Future<List<PIIClassification>> getAllClassifications() async {
    try {
      final querySnapshot = await _firestore
          .collection('pii_catalog')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PIIClassification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all classifications: $e');
      return [];
    }
  }
}
