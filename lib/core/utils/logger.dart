import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
/// Only logs in debug mode to avoid performance impact in production
class Logger {
  static const bool _isDebugMode = kDebugMode;

  /// Log general information
  static void info(String message, [String? tag]) {
    if (_isDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('INFO: $prefix$message');
    }
  }

  /// Log errors with optional stack trace
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
  }

  /// Log warnings
  static void warn(String message) {
    if (_isDebugMode) {
      debugPrint('WARN: $message');
    }
  }

  /// Log API calls
  static void api(String method, String url, [int? statusCode]) {
    if (_isDebugMode) {
      final status = statusCode != null ? ' [$statusCode]' : '';
      debugPrint('API: $method $url$status');
    }
  }
}
