import '../../../../core/error/exceptions.dart';
import '../repositories/onboarding_repository.dart';

/// Use case for checking if this is the first app launch
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// checking first launch status.
class CheckFirstLaunch {
  final OnboardingRepository repository;

  const CheckFirstLaunch(this.repository);

  /// Executes the use case and returns first launch status
  ///
  /// Returns true if it's the first launch, false otherwise.
  /// Throws a [StorageException] if the repository operation fails.
  Future<bool> call() async {
    try {
      return await repository.isFirstLaunch();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to check first launch status: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

