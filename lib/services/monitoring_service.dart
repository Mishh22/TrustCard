import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import '../models/error_event.dart';

class MonitoringService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log error event
  static Future<void> logError({
    String? userId,
    required String screen,
    required String action,
    required String errorCode,
    required String stackTrace,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String platform = 'unknown';
      String appVersion = 'unknown';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        platform = 'android';
        appVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        platform = 'ios';
        appVersion = iosInfo.systemVersion;
      }

      final errorEvent = ErrorEvent(
        id: _firestore.collection('error_events').doc().id,
        userId: userId,
        platform: platform,
        appVersion: appVersion,
        screen: screen,
        action: action,
        errorCode: errorCode,
        stackHash: _generateStackHash(stackTrace),
        occurredAt: DateTime.now(),
      );

      await _firestore
          .collection('error_events')
          .doc(errorEvent.id)
          .set(errorEvent.toMap());
    } catch (e) {
      print('Error logging error event: $e');
    }
  }

  // Log performance metrics
  static Future<void> logPerformance({
    required String userId,
    required String action,
    required int latencyMs,
    required String screen,
  }) async {
    try {
      await _firestore.collection('performance_metrics').add({
        'userId': userId,
        'action': action,
        'latencyMs': latencyMs,
        'screen': screen,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (e) {
      print('Error logging performance metrics: $e');
    }
  }

  // Log API call metrics
  static Future<void> logAPICall({
    required String endpoint,
    required int responseTime,
    required int statusCode,
    String? userId,
  }) async {
    try {
      await _firestore.collection('api_metrics').add({
        'endpoint': endpoint,
        'responseTime': responseTime,
        'statusCode': statusCode,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (e) {
      print('Error logging API call: $e');
    }
  }

  // Get error events for user
  static Future<List<ErrorEvent>> getErrorEvents(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('error_events')
          .where('userId', isEqualTo: userId)
          .orderBy('occurredAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => ErrorEvent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting error events: $e');
      return [];
    }
  }

  // Get performance metrics
  static Future<List<Map<String, dynamic>>> getPerformanceMetrics({
    String? userId,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection('performance_metrics')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting performance metrics: $e');
      return [];
    }
  }

  // Get API metrics
  static Future<List<Map<String, dynamic>>> getAPIMetrics({
    int limit = 100,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('api_metrics')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting API metrics: $e');
      return [];
    }
  }

  // Generate hash for stack trace
  static String _generateStackHash(String stackTrace) {
    final bytes = utf8.encode(stackTrace);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Log session start
  static Future<void> logSessionStart({
    required String userId,
    required String screen,
  }) async {
    try {
      await _firestore.collection('session_events').add({
        'userId': userId,
        'eventType': 'session_start',
        'screen': screen,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (e) {
      print('Error logging session start: $e');
    }
  }

  // Log session end
  static Future<void> logSessionEnd({
    required String userId,
    required String screen,
    required int durationSeconds,
  }) async {
    try {
      await _firestore.collection('session_events').add({
        'userId': userId,
        'eventType': 'session_end',
        'screen': screen,
        'durationSeconds': durationSeconds,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (e) {
      print('Error logging session end: $e');
    }
  }
}
