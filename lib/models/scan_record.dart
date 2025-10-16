import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for tracking scan history and analytics
class ScanRecord {
  final String id;
  final String cardId;
  final String cardOwnerId;
  final String scannerId;
  final String scannerName;
  final String? scannerCompany;
  final DateTime scannedAt;
  final String? location;
  final Map<String, dynamic>? metadata;

  const ScanRecord({
    required this.id,
    required this.cardId,
    required this.cardOwnerId,
    required this.scannerId,
    required this.scannerName,
    this.scannerCompany,
    required this.scannedAt,
    this.location,
    this.metadata,
  });

  /// Create ScanRecord from Firestore document
  factory ScanRecord.fromMap(Map<String, dynamic> data, String id) {
    return ScanRecord(
      id: id,
      cardId: data['cardId'] ?? '',
      cardOwnerId: data['cardOwnerId'] ?? '',
      scannerId: data['scannerId'] ?? '',
      scannerName: data['scannerName'] ?? '',
      scannerCompany: data['scannerCompany'],
      scannedAt: (data['scannedAt'] as Timestamp).toDate(),
      location: data['location'],
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'cardOwnerId': cardOwnerId,
      'scannerId': scannerId,
      'scannerName': scannerName,
      'scannerCompany': scannerCompany,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'location': location,
      'metadata': metadata,
    };
  }

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Model for scan analytics and insights
class ScanAnalytics {
  final String cardId;
  final int totalScans;
  final int uniqueScanners;
  final DateTime? lastScanned;
  final DateTime? firstScanned;
  final Map<String, int> scansByDay;
  final Map<String, int> scansByHour;
  final List<String> topScanners;
  final double averageScansPerDay;

  const ScanAnalytics({
    required this.cardId,
    required this.totalScans,
    required this.uniqueScanners,
    this.lastScanned,
    this.firstScanned,
    required this.scansByDay,
    required this.scansByHour,
    required this.topScanners,
    required this.averageScansPerDay,
  });

  /// Create ScanAnalytics from Firestore document
  factory ScanAnalytics.fromMap(Map<String, dynamic> data) {
    return ScanAnalytics(
      cardId: data['cardId'] ?? '',
      totalScans: data['totalScans'] ?? 0,
      uniqueScanners: data['uniqueScanners'] ?? 0,
      lastScanned: data['lastScanned'] != null 
          ? (data['lastScanned'] as Timestamp).toDate() 
          : null,
      firstScanned: data['firstScanned'] != null 
          ? (data['firstScanned'] as Timestamp).toDate() 
          : null,
      scansByDay: data['scansByDay'] != null 
          ? Map<String, int>.from(data['scansByDay']) 
          : {},
      scansByHour: data['scansByHour'] != null 
          ? Map<String, int>.from(data['scansByHour']) 
          : {},
      topScanners: data['topScanners'] != null 
          ? List<String>.from(data['topScanners']) 
          : [],
      averageScansPerDay: (data['averageScansPerDay'] ?? 0.0).toDouble(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'totalScans': totalScans,
      'uniqueScanners': uniqueScanners,
      'lastScanned': lastScanned != null ? Timestamp.fromDate(lastScanned!) : null,
      'firstScanned': firstScanned != null ? Timestamp.fromDate(firstScanned!) : null,
      'scansByDay': scansByDay,
      'scansByHour': scansByHour,
      'topScanners': topScanners,
      'averageScansPerDay': averageScansPerDay,
    };
  }
}