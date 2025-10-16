import 'package:flutter/foundation.dart';

/// Simple logging utility for the app
class Logger {
  static const bool _isDebugMode = kDebugMode;
  
  /// Log debug messages (only in debug mode)
  static void debug(String message) {
    if (_isDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  /// Log info messages (only in debug mode)
  static void info(String message) {
    if (_isDebugMode) {
      print('[INFO] $message');
    }
  }
  
  /// Log warning messages (always shown)
  static void warning(String message) {
    print('[WARNING] $message');
  }
  
  /// Log error messages (always shown)
  static void error(String message) {
    print('[ERROR] $message');
  }
  
  /// Log success messages (only in debug mode)
  static void success(String message) {
    if (_isDebugMode) {
      print('[SUCCESS] $message');
    }
  }
}
