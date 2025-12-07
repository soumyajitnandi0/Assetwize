import '../../../../core/error/exceptions.dart';
import '../entities/jewellery.dart';
import '../repositories/jewellery_repository.dart';

/// Use case for fetching all jewellery items
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching all jewellery items.
class GetJewelleries {
  final JewelleryRepository repository;

  const GetJewelleries(this.repository);

  /// Executes the use case and returns a list of jewellery items
  ///
  /// Returns an empty list if no jewellery items are found.
  /// Throws [StorageException] if the repository fails
  Future<List<Jewellery>> call() async {
    try {
      return await repository.getJewelleries();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch jewellery items: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

