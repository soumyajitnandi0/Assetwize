import '../../domain/entities/realty.dart';

/// Data model for realty, extending the domain entity
///
/// Handles serialization/deserialization for storage.
class RealtyModel extends Realty {
  const RealtyModel({
    required super.id,
    required super.propertyType,
    required super.address,
    super.city,
    super.state,
    super.zipCode,
    super.country,
    super.area,
    super.areaUnit,
    super.purchasePrice,
    super.purchaseDate,
    super.currentValue,
    super.lastValuationDate,
    super.propertyNumber,
    super.description,
    super.imageUrl,
    super.notes,
    super.metadata,
  });

  /// Creates a RealtyModel from JSON
  factory RealtyModel.fromJson(Map<String, dynamic> json) {
    return RealtyModel(
      id: json['id'] as String,
      propertyType: json['propertyType'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
      area: json['area'] != null ? (json['area'] as num).toDouble() : null,
      areaUnit: json['areaUnit'] as String?,
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      currentValue: json['currentValue'] != null
          ? (json['currentValue'] as num).toDouble()
          : null,
      lastValuationDate: json['lastValuationDate'] != null
          ? DateTime.parse(json['lastValuationDate'] as String)
          : null,
      propertyNumber: json['propertyNumber'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Creates a RealtyModel from a domain entity
  factory RealtyModel.fromEntity(Realty realty) {
    return RealtyModel(
      id: realty.id,
      propertyType: realty.propertyType,
      address: realty.address,
      city: realty.city,
      state: realty.state,
      zipCode: realty.zipCode,
      country: realty.country,
      area: realty.area,
      areaUnit: realty.areaUnit,
      purchasePrice: realty.purchasePrice,
      purchaseDate: realty.purchaseDate,
      currentValue: realty.currentValue,
      lastValuationDate: realty.lastValuationDate,
      propertyNumber: realty.propertyNumber,
      description: realty.description,
      imageUrl: realty.imageUrl,
      notes: realty.notes,
      metadata: realty.metadata,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyType': propertyType,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'area': area,
      'areaUnit': areaUnit,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'currentValue': currentValue,
      'lastValuationDate': lastValuationDate?.toIso8601String(),
      'propertyNumber': propertyNumber,
      'description': description,
      'imageUrl': imageUrl,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

