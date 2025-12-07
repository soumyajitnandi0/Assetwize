import '../../../../core/error/exceptions.dart';
import '../entities/jewellery.dart';
import '../repositories/jewellery_repository.dart';

/// Use case for fetching a single jewellery item detail
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching a single jewellery item by ID.
class GetJewelleryDetail {
  final JewelleryRepository repository;

  const GetJewelleryDetail(this.repository);

  /// Executes the use case and returns a single jewellery item
  ///
  /// [id] - The unique identifier of the jewellery item
  ///
  /// Throws [ValidationException] if id is empty
  /// Throws [NotFoundException] if the item is not found
  /// Throws [StorageException] if the repository fails
  Future<Jewellery> call(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Jewellery ID cannot be empty');
    }

    try {
      return await repository.getJewellery(id.trim());
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch jewellery detail: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

