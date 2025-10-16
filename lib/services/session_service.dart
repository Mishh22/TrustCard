import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/session_data.dart';

class SessionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static String? _currentSessionId;

  // Start new session
  static Future<String> startSession({
    required String userId,
    String? screen,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String networkType = 'unknown';
      // Network type detection simplified for now
      networkType = 'wifi'; // Default to wifi for emulator

      String appVersion = 'unknown';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        appVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        appVersion = iosInfo.systemVersion;
      }

      final sessionData = SessionData(
        id: _firestore.collection('sessions').doc().id,
        userId: userId,
        sessionStart: DateTime.now(),
        deviceId: Platform.isAndroid ? (await deviceInfo.androidInfo).id : 'ios_device',
        appVersion: appVersion,
        networkType: networkType,
        screen: screen,
      );

      _currentSessionId = sessionData.id;
      await _firestore
          .collection('sessions')
          .doc(sessionData.id)
          .set(sessionData.toMap());

      return sessionData.id;
    } catch (e) {
      print('Error starting session: $e');
      return '';
    }
  }

  // End current session
  static Future<void> endSession() async {
    try {
      if (_currentSessionId != null) {
        final sessionDoc = await _firestore
            .collection('sessions')
            .doc(_currentSessionId!)
            .get();

        if (sessionDoc.exists) {
          final sessionData = SessionData.fromMap(
            sessionDoc.data()!,
            sessionDoc.id,
          );

          final duration = DateTime.now().difference(sessionData.sessionStart).inSeconds;

          await _firestore
              .collection('sessions')
              .doc(_currentSessionId!)
              .update({
            'sessionEnd': DateTime.now().toIso8601String(),
            'durationSeconds': duration,
            'isActive': false,
          });
        }
        _currentSessionId = null;
      }
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Update session screen
  static Future<void> updateSessionScreen(String screen) async {
    try {
      if (_currentSessionId != null) {
        await _firestore
            .collection('sessions')
            .doc(_currentSessionId!)
            .update({
          'screen': screen,
        });
      }
    } catch (e) {
      print('Error updating session screen: $e');
    }
  }

  // Get user sessions
  static Future<List<SessionData>> getUserSessions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('sessionStart', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user sessions: $e');
      return [];
    }
  }

  // Get session stream for real-time updates
  static Stream<List<SessionData>> getUserSessionsStream(String userId) {
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('sessionStart', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionData.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get active sessions
  static Future<List<SessionData>> getActiveSessions() async {
    try {
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .orderBy('sessionStart', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting active sessions: $e');
      return [];
    }
  }

  // Track session event
  static Future<void> trackSessionEvent({
    required String userId,
    required String eventType,
    required String screen,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('session_events').add({
        'userId': userId,
        'eventType': eventType,
        'screen': screen,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _currentSessionId,
      });
    } catch (e) {
      print('Error tracking session event: $e');
    }
  }

  // Get session analytics
  static Future<Map<String, dynamic>> getSessionAnalytics(String userId) async {
    try {
      final sessions = await getUserSessions(userId);
      
      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'averageDuration': 0,
          'totalDuration': 0,
          'mostUsedScreen': null,
        };
      }

      final totalSessions = sessions.length;
      final totalDuration = sessions
          .where((s) => s.durationSeconds != null)
          .fold(0, (sum, s) => sum + (s.durationSeconds ?? 0));
      final averageDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;

      // Count screen usage
      final screenCounts = <String, int>{};
      for (final session in sessions) {
        if (session.screen != null) {
          screenCounts[session.screen!] = (screenCounts[session.screen!] ?? 0) + 1;
        }
      }

      final mostUsedScreen = screenCounts.isNotEmpty
          ? screenCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;

      return {
        'totalSessions': totalSessions,
        'averageDuration': averageDuration,
        'totalDuration': totalDuration,
        'mostUsedScreen': mostUsedScreen,
      };
    } catch (e) {
      print('Error getting session analytics: $e');
      return {};
    }
  }
}
