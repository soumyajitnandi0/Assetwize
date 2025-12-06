/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception thrown when a server request fails
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a cache operation fails
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when data validation fails
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a network operation fails
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}
