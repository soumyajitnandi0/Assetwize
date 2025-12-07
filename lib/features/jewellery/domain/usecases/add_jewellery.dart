import '../../../../core/error/exceptions.dart';
import '../entities/jewellery.dart';
import '../repositories/jewellery_repository.dart';

/// Use case for adding or updating a jewellery item
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates the jewellery data and saves it to the repository.
class AddJewellery {
  final JewelleryRepository repository;

  const AddJewellery(this.repository);

  /// Executes the use case and saves the jewellery item
  ///
  /// [jewellery] - The jewellery item to save
  ///
  /// Throws [ValidationException] if required fields are missing
  /// Throws [StorageException] if save fails
  Future<void> call(Jewellery jewellery) async {
    // Validate required fields
    if (jewellery.category.trim().isEmpty) {
      throw const ValidationException('Category cannot be empty');
    }
    if (jewellery.itemName.trim().isEmpty) {
      throw const ValidationException('Item name cannot be empty');
    }

    try {
      await repository.addJewellery(jewellery);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to save jewellery: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

