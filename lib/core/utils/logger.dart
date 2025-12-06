import 'package:flutter/foundation.dart';

/// Centralized logging utility
///
/// In production, this can be extended to send logs to
/// analytics services like Firebase Analytics, Sentry, etc.
///
/// Usage:
/// ```dart
/// Logger.info('User logged in');
/// Logger.warning('Low memory detected');
/// Logger.error('Failed to load data', error, stackTrace);
/// ```
class Logger {
  Logger._();

  /// Logs an informational message
  ///
  /// Use for general information that might be useful for debugging.
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
    // TODO: Send to analytics service in production
    // Example: FirebaseAnalytics.logEvent(name: 'info', parameters: {'message': message});
  }

  /// Logs a warning message
  ///
  /// Use for situations that are unusual but not necessarily errors.
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
    // TODO: Send to analytics service in production
  }

  /// Logs an error message
  ///
  /// Use for errors that should be tracked and potentially reported.
  /// In production, these should be sent to crash reporting services.
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
    // TODO: Send to crash reporting service in production
    // Example: Sentry.captureException(error, stackTrace: stackTrace);
  }

  /// Logs a debug message (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
  }
}
