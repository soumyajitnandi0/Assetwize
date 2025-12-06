import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures represent expected errors that can occur during
/// business logic execution. They are different from exceptions
/// which represent unexpected errors.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when a requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Failure when network operations fail
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Failure when data validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure when a storage operation fails
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

/// Failure for unknown/unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}
