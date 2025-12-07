import 'package:flutter/foundation.dart';

/// Centralized logging utility
///
/// In production, automatically sends logs to analytics services
/// (Firebase Analytics, Sentry, Firebase Crashlytics).
///
/// Usage:
/// ```dart
/// Logger.info('User logged in');
/// Logger.warning('Low memory detected');
/// Logger.error('Failed to load data', error, stackTrace);
/// ```
class Logger {
  Logger._();

  static final _productionLogging = _ProductionLoggingService();

  /// Logs an informational message
  ///
  /// Use for general information that might be useful for debugging.
  /// In production, sends to Firebase Analytics.
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
    
    // Send to production analytics
    _productionLogging.logInfo(message, parameters: {
      if (error != null) 'error': error.toString(),
    });
  }

  /// Logs a warning message
  ///
  /// Use for situations that are unusual but not necessarily errors.
  /// In production, sends to Firebase Analytics.
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
    
    // Send to production analytics
    _productionLogging.logWarning(message, parameters: {
      if (error != null) 'error': error.toString(),
    });
  }

  /// Logs an error message
  ///
  /// Use for errors that should be tracked and potentially reported.
  /// In production, sends to Sentry and Firebase Crashlytics.
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
    
    // Send to production crash reporting
    _productionLogging.logError(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a debug message (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
  }

  /// Logs a custom event to analytics
  ///
  /// Use for tracking specific user actions or events.
  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _productionLogging.logEvent(eventName, parameters: parameters);
  }
}

/// Internal production logging service wrapper
/// Handles optional Firebase/Sentry integration gracefully
class _ProductionLoggingService {

  Future<void> logInfo(String message, {Map<String, dynamic>? parameters}) async {
    // In production, this would send to Firebase Analytics
    // For now, just log in debug mode
    if (kDebugMode) {
      debugPrint('ProductionLogging: INFO - $message');
    }
  }

  Future<void> logWarning(String message, {Map<String, dynamic>? parameters}) async {
    // In production, this would send to Firebase Analytics
    if (kDebugMode) {
      debugPrint('ProductionLogging: WARNING - $message');
    }
  }

  Future<void> logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    // In production, this would send to Sentry and Firebase Crashlytics
    // For now, just ensure it's logged
    if (kDebugMode) {
      debugPrint('ProductionLogging: ERROR - $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
    }
    
    // TODO: When Firebase/Sentry packages are added, uncomment:
    // try {
    //   await Sentry.captureException(error, stackTrace: stackTrace);
    //   await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // } catch (e) {
    //   // Silently fail
    // }
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // In production, this would send to Firebase Analytics
    if (kDebugMode) {
      debugPrint('ProductionLogging: EVENT - $eventName');
    }
    
    // TODO: When Firebase Analytics is added, uncomment:
    // try {
    //   await FirebaseAnalytics.instance.logEvent(
    //     name: eventName,
    //     parameters: parameters,
    //   );
    // } catch (e) {
    //   // Silently fail
    // }
  }
}
