import '../entities/jewellery.dart';

/// Abstract repository interface for jewellery data
///
/// This defines the contract for jewellery data operations.
/// Implementations can use local storage, remote APIs, or both.
abstract class JewelleryRepository {
  /// Gets all jewellery items
  ///
  /// Returns a list of all jewellery items stored.
  /// Returns an empty list if no items are found.
  Future<List<Jewellery>> getJewelleries();

  /// Gets a single jewellery item by ID
  ///
  /// [id] - The unique identifier of the jewellery item
  /// Throws [NotFoundException] if the item is not found
  Future<Jewellery> getJewellery(String id);

  /// Adds or updates a jewellery item
  ///
  /// If the jewellery has an existing ID, it will be updated.
  /// If the ID is new, a new item will be created.
  /// [jewellery] - The jewellery item to save
  Future<void> addJewellery(Jewellery jewellery);

  /// Deletes a jewellery item
  ///
  /// [id] - The unique identifier of the jewellery item to delete
  /// Throws [NotFoundException] if the item is not found
  Future<void> deleteJewellery(String id);

  /// Clears all jewellery data
  ///
  /// Use with caution - this will delete all jewellery items.
  Future<void> clearAll();
}

