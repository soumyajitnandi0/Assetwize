/// Abstract repository interface for onboarding data
/// 
/// This interface defines the contract for onboarding state operations.
abstract class OnboardingRepository {
  /// Checks if this is the first app launch
  /// Returns true if it's the first launch, false otherwise.
  /// Throws [StorageException] if the check fails.
  Future<bool> isFirstLaunch();

  /// Marks that the app has been launched (not first launch anymore)
  /// Throws [StorageException] if the operation fails.
  Future<void> setFirstLaunchComplete();
}

