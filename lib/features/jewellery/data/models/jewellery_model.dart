import '../../domain/entities/jewellery.dart';

/// Data model for jewellery, extending the domain entity
///
/// Handles serialization/deserialization for storage.
class JewelleryModel extends Jewellery {
  const JewelleryModel({
    required super.id,
    required super.category,
    required super.itemName,
    super.description,
    super.weight,
    super.purity,
    super.purchasePrice,
    super.purchaseDate,
    super.purchaseLocation,
    super.currentValue,
    super.lastValuationDate,
    super.imageUrl,
    super.notes,
    super.metadata,
  });

  /// Creates a JewelleryModel from JSON
  factory JewelleryModel.fromJson(Map<String, dynamic> json) {
    return JewelleryModel(
      id: json['id'] as String,
      category: json['category'] as String,
      itemName: json['itemName'] as String,
      description: json['description'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      purity: json['purity'] as String?,
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      purchaseLocation: json['purchaseLocation'] as String?,
      currentValue: json['currentValue'] != null
          ? (json['currentValue'] as num).toDouble()
          : null,
      lastValuationDate: json['lastValuationDate'] != null
          ? DateTime.parse(json['lastValuationDate'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Creates a JewelleryModel from a domain entity
  factory JewelleryModel.fromEntity(Jewellery jewellery) {
    return JewelleryModel(
      id: jewellery.id,
      category: jewellery.category,
      itemName: jewellery.itemName,
      description: jewellery.description,
      weight: jewellery.weight,
      purity: jewellery.purity,
      purchasePrice: jewellery.purchasePrice,
      purchaseDate: jewellery.purchaseDate,
      purchaseLocation: jewellery.purchaseLocation,
      currentValue: jewellery.currentValue,
      lastValuationDate: jewellery.lastValuationDate,
      imageUrl: jewellery.imageUrl,
      notes: jewellery.notes,
      metadata: jewellery.metadata,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'itemName': itemName,
      'description': description,
      'weight': weight,
      'purity': purity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchaseLocation': purchaseLocation,
      'currentValue': currentValue,
      'lastValuationDate': lastValuationDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

