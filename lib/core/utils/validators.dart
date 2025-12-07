import '../constants/app_constants.dart';

/// Input validation utilities
///
/// Provides reusable validation functions for form inputs
/// and data validation throughout the application.
/// Uses constants from AppConstants for consistent validation rules.
class Validators {
  Validators._();

  /// Validates that a string is not empty
  ///
  /// Returns null if valid, error message if invalid.
  static String? notEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  /// Validates that a string has minimum length
  ///
  /// Returns null if valid, error message if invalid.
  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that a string has maximum length
  ///
  /// Returns null if valid, error message if invalid.
  static String? maxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }

  /// Validates an email address format
  ///
  /// Returns null if valid, error message if invalid.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a phone number format
  ///
  /// Returns null if valid, error message if invalid.
  /// Uses constants from AppConstants for min/max length.
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check length using constants
    if (cleaned.length < AppConstants.minPhoneLength) {
      return 'Phone number must be at least ${AppConstants.minPhoneLength} digits';
    }
    if (cleaned.length > AppConstants.maxPhoneLength) {
      return 'Phone number must be at most ${AppConstants.maxPhoneLength} digits';
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates a name field
  ///
  /// Returns null if valid, error message if invalid.
  /// Uses constants from AppConstants for min/max length.
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    final trimmed = value.trim();
    
    if (trimmed.length < AppConstants.minNameLength) {
      return '$fieldName must be at least ${AppConstants.minNameLength} character';
    }
    if (trimmed.length > AppConstants.maxNameLength) {
      return '$fieldName must be at most ${AppConstants.maxNameLength} characters';
    }
    
    return null;
  }

  /// Validates that a date is not in the past
  ///
  /// Returns null if valid, error message if invalid.
  static String? notInPast(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName cannot be empty';
    }
    if (value.isBefore(DateTime.now())) {
      return '$fieldName cannot be in the past';
    }
    return null;
  }

  /// Validates that end date is after start date
  ///
  /// Returns null if valid, error message if invalid.
  static String? dateRange(
    DateTime? startDate,
    DateTime? endDate, {
    String startFieldName = 'Start date',
    String endFieldName = 'End date',
  }) {
    if (startDate == null || endDate == null) {
      return 'Both dates must be provided';
    }
    if (endDate.isBefore(startDate)) {
      return '$endFieldName must be after $startFieldName';
    }
    return null;
  }
}
