import '../../../../core/error/exceptions.dart';
import '../repositories/onboarding_repository.dart';

/// Use case for completing onboarding
///
/// This is a pure domain use case with no Flutter dependencies.
/// Marks that the user has completed the onboarding flow.
class CompleteOnboarding {
  final OnboardingRepository repository;

  const CompleteOnboarding(this.repository);

  /// Executes the use case and marks onboarding as complete
  ///
  /// Throws [StorageException] if the operation fails.
  Future<void> call() async {
    try {
      await repository.setFirstLaunchComplete();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to complete onboarding: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

