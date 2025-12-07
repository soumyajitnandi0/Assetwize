import 'package:flutter/foundation.dart';
// Conditional imports for production services
// These will only be used if the packages are added to pubspec.yaml
// For now, we'll use dynamic calls to avoid compilation errors if packages aren't added

/// Production logging service
///
/// Handles logging to production services like Firebase Analytics,
/// Firebase Crashlytics, and Sentry.
/// Falls back gracefully if services are not initialized.
class ProductionLoggingService {
  static final ProductionLoggingService _instance = ProductionLoggingService._internal();
  factory ProductionLoggingService() => _instance;
  ProductionLoggingService._internal();

  bool _isInitialized = false;
  dynamic _analytics;
  dynamic _crashlytics;

  /// Initializes production logging services
  ///
  /// Should be called during app startup after Firebase is initialized.
  /// Accepts dynamic types to allow optional Firebase packages.
  Future<void> initialize({
    dynamic analytics,
    dynamic crashlytics,
  }) async {
    if (kDebugMode) {
      // Skip initialization in debug mode to avoid unnecessary setup
      return;
    }

    try {
      _analytics = analytics;
      _crashlytics = crashlytics;
      _isInitialized = true;
    } catch (e) {
      // Log but don't throw - app should continue even if logging fails
      debugPrint('ProductionLoggingService: Failed to initialize: $e');
    }
  }

  /// Logs an informational event to analytics
  Future<void> logInfo(String message, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      // Use dynamic call to avoid compilation errors if Firebase Analytics isn't added
      await _analytics.logEvent(
        name: 'info',
        parameters: {
          'message': message,
          ...?parameters,
        },
      );
    } catch (e) {
      // Silently fail - don't break app if analytics fails
      debugPrint('ProductionLoggingService: Failed to log info: $e');
    }
  }

  /// Logs a warning event to analytics
  Future<void> logWarning(String message, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics.logEvent(
        name: 'warning',
        parameters: {
          'message': message,
          ...?parameters,
        },
      );
    } catch (e) {
      debugPrint('ProductionLoggingService: Failed to log warning: $e');
    }
  }

  /// Logs an error to crash reporting services
  Future<void> logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) return;

    try {
      // Log to Sentry (if available)
      try {
        // Dynamic import check - only use if Sentry is available
        final sentry = await _getSentryIfAvailable();
        if (sentry != null && error != null && stackTrace != null) {
          await sentry.captureException(
            error,
            stackTrace: stackTrace,
          );
        }
      } catch (_) {
        // Sentry not available or failed - continue
      }

      // Log to Firebase Crashlytics (if available)
      if (_crashlytics != null && error != null) {
        try {
          await _crashlytics.recordError(
            error,
            stackTrace,
            reason: message,
            fatal: false,
          );
        } catch (_) {
          // Crashlytics failed - continue
        }
      }
    } catch (e) {
      // Silently fail - don't break app if crash reporting fails
      debugPrint('ProductionLoggingService: Failed to log error: $e');
    }
  }

  /// Logs a custom event to analytics
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('ProductionLoggingService: Failed to log event: $e');
    }
  }

  /// Sets user properties for analytics
  Future<void> setUserProperty(String name, String? value) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('ProductionLoggingService: Failed to set user property: $e');
    }
  }

  /// Helper to get Sentry if available (dynamic import)
  Future<dynamic> _getSentryIfAvailable() async {
    try {
      // This will only work if sentry_flutter is added to pubspec.yaml
      // For now, return null to avoid compilation errors
      return null;
    } catch (_) {
      return null;
    }
  }
}

