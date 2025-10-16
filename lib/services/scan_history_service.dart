import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_record.dart';
import '../utils/logger.dart';

/// Service for managing scan history and analytics
class ScanHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Record a scan interaction
  static Future<bool> recordScan({
    required String cardId,
    required String cardOwnerId,
    required String scannerId,
    required String scannerName,
    String? scannerCompany,
    String? location,
    Map<String, dynamic>? metadata,
    String? tenantId,
    String? effectiveRole,
  }) async {
    try {
      final scanId = _firestore.collection('scan_history').doc().id;
      
      final scanRecord = ScanRecord(
        id: scanId,
        cardId: cardId,
        cardOwnerId: cardOwnerId,
        scannerId: scannerId,
        scannerName: scannerName,
        scannerCompany: scannerCompany,
        scannedAt: DateTime.now(),
        location: location,
        metadata: metadata,
      );

      // Add enterprise fields to scan record
      final scanData = scanRecord.toMap();
      scanData['tenantId'] = tenantId;
      scanData['effectiveRole'] = effectiveRole;
      scanData['eventId'] = const Uuid().v7();
      scanData['schemaVersion'] = '1.0';
      scanData['source'] = 'mobile';
      scanData['receivedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection('scan_history').doc(scanId).set(scanData);
      
      // Update scan analytics
      await _updateScanAnalytics(cardId, cardOwnerId);
      
      Logger.success('Scan recorded successfully: $scanId');
      return true;
    } catch (e) {
      Logger.error('Error recording scan: $e');
      return false;
    }
  }

  /// Get scan history for a card owner
  static Future<List<ScanRecord>> getScanHistory(String cardOwnerId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_history')
          .where('cardOwnerId', isEqualTo: cardOwnerId)
          .limit(limit * 2) // Get more records to sort client-side
          .get();

      final records = querySnapshot.docs
          .map((doc) => ScanRecord.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort client-side by scannedAt descending
      records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      
      // Return limited results
      return records.take(limit).toList();
    } catch (e) {
      Logger.error('Error getting scan history: $e');
      return [];
    }
  }

  /// Get scan history stream for real-time updates
  static Stream<List<ScanRecord>> getScanHistoryStream(String cardOwnerId, {int limit = 50}) {
    // Use a simpler query without orderBy to avoid index requirements
    return _firestore
        .collection('scan_history')
        .where('cardOwnerId', isEqualTo: cardOwnerId)
        .limit(limit * 2) // Get more records to sort client-side
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => ScanRecord.fromMap(doc.data(), doc.id))
              .toList();
          
          // Sort client-side by scannedAt descending
          records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
          
          // Return limited results
          return records.take(limit).toList();
        });
  }

  /// Get scan history stream for a specific card (real-time updates)
  static Stream<List<ScanRecord>> getScanHistoryStreamForCard(
    String cardOwnerId,
    String scannedCardId, {
    int limit = 50,
  }) {
    // For now, get all scans and filter client-side to avoid Firestore index requirements
    return _firestore
        .collection('scan_history')
        .where('cardOwnerId', isEqualTo: cardOwnerId)
        .orderBy('scannedAt', descending: true)
        .limit(limit * 2) // Get more records to account for filtering
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanRecord.fromMap(doc.data(), doc.id))
            .where((record) => record.cardId == scannedCardId) // Filter client-side
            .take(limit)
            .toList());
  }

  /// Get scan analytics for a card
  static Future<ScanAnalytics?> getScanAnalytics(String cardId) async {
    try {
      final doc = await _firestore
          .collection('scan_analytics')
          .doc(cardId)
          .get();

      if (doc.exists) {
        return ScanAnalytics.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      Logger.error('Error getting scan analytics: $e');
      return null;
    }
  }

  /// Get scan analytics stream for real-time updates
  static Stream<ScanAnalytics?> getScanAnalyticsStream(String cardId) {
    return _firestore
        .collection('scan_analytics')
        .doc(cardId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return ScanAnalytics.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  /// Get cards scanned by a user
  static Future<List<ScanRecord>> getScannedByUser(String scannerId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('scan_history')
          .where('scannerId', isEqualTo: scannerId)
          .orderBy('scannedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Logger.error('Error getting scanned cards: $e');
      return [];
    }
  }

  /// Check if two users have scanned each other (mutual scan)
  static Future<bool> checkMutualScan(String user1Id, String user2Id) async {
    try {
      // Check if user1 scanned user2
      final user1ScannedUser2 = await _firestore
          .collection('scan_history')
          .where('scannerId', isEqualTo: user1Id)
          .where('cardOwnerId', isEqualTo: user2Id)
          .limit(1)
          .get();

      // Check if user2 scanned user1
      final user2ScannedUser1 = await _firestore
          .collection('scan_history')
          .where('scannerId', isEqualTo: user2Id)
          .where('cardOwnerId', isEqualTo: user1Id)
          .limit(1)
          .get();

      return user1ScannedUser2.docs.isNotEmpty && user2ScannedUser1.docs.isNotEmpty;
    } catch (e) {
      Logger.error('Error checking mutual scan: $e');
      return false;
    }
  }

  /// Delete scan history for a user (privacy feature)
  static Future<bool> deleteScanHistory(String userId) async {
    try {
      // Delete scans where user is the card owner
      final ownerScans = await _firestore
          .collection('scan_history')
          .where('cardOwnerId', isEqualTo: userId)
          .get();

      for (final doc in ownerScans.docs) {
        await doc.reference.delete();
      }

      // Delete scans where user is the scanner
      final scannerScans = await _firestore
          .collection('scan_history')
          .where('scannerId', isEqualTo: userId)
          .get();

      for (final doc in scannerScans.docs) {
        await doc.reference.delete();
      }

      Logger.success('Scan history deleted for user: $userId');
      return true;
    } catch (e) {
      Logger.error('Error deleting scan history: $e');
      return false;
    }
  }

  /// Update scan analytics for a card
  static Future<void> _updateScanAnalytics(String cardId, String cardOwnerId) async {
    try {
      // Get all scans for this card
      final scans = await _firestore
          .collection('scan_history')
          .where('cardId', isEqualTo: cardId)
          .get();

      if (scans.docs.isEmpty) return;

      // Calculate analytics
      final totalScans = scans.docs.length;
      final uniqueScanners = scans.docs
          .map((doc) => doc.data()['scannerId'])
          .toSet()
          .length;

      final scanDates = scans.docs
          .map((doc) => (doc.data()['scannedAt'] as Timestamp).toDate())
          .toList()
        ..sort();

      final firstScanned = scanDates.isNotEmpty ? scanDates.first : null;
      final lastScanned = scanDates.isNotEmpty ? scanDates.last : null;

      // Calculate scans by day and hour
      final scansByDay = <String, int>{};
      final scansByHour = <String, int>{};
      final scannerCounts = <String, int>{};

      for (final doc in scans.docs) {
        final data = doc.data();
        final scannedAt = (data['scannedAt'] as Timestamp).toDate();
        final scannerId = data['scannerId'] as String;

        // Count by day
        final dayKey = '${scannedAt.year}-${scannedAt.month.toString().padLeft(2, '0')}-${scannedAt.day.toString().padLeft(2, '0')}';
        scansByDay[dayKey] = (scansByDay[dayKey] ?? 0) + 1;

        // Count by hour
        final hourKey = scannedAt.hour.toString().padLeft(2, '0');
        scansByHour[hourKey] = (scansByHour[hourKey] ?? 0) + 1;

        // Count by scanner
        scannerCounts[scannerId] = (scannerCounts[scannerId] ?? 0) + 1;
      }

      // Get top scanners
      final topScanners = scannerCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      final topScannerIds = topScanners.take(5).map((e) => e.key).toList();

      // Calculate average scans per day
      final daysDifference = firstScanned != null && lastScanned != null
          ? lastScanned.difference(firstScanned).inDays + 1
          : 1;
      final averageScansPerDay = totalScans / daysDifference;

      // Create analytics document
      final analytics = ScanAnalytics(
        cardId: cardId,
        totalScans: totalScans,
        uniqueScanners: uniqueScanners,
        lastScanned: lastScanned,
        firstScanned: firstScanned,
        scansByDay: scansByDay,
        scansByHour: scansByHour,
        topScanners: topScannerIds,
        averageScansPerDay: averageScansPerDay,
      );

      await _firestore
          .collection('scan_analytics')
          .doc(cardId)
          .set(analytics.toMap());

      Logger.success('Scan analytics updated for card: $cardId');
    } catch (e) {
      Logger.error('Error updating scan analytics: $e');
    }
  }
}