import '../../domain/entities/garage.dart';

/// Garage model extending the domain entity
/// Handles data serialization/deserialization
class GarageModel extends Garage {
  const GarageModel({
    required super.id,
    required super.vehicleType,
    required super.registrationNumber,
    super.make,
    super.model,
    super.year,
    super.color,
    super.insuranceProvider,
    super.policyNumber,
    super.insuranceStartDate,
    super.insuranceEndDate,
    super.imageUrl,
    super.notes,
    super.metadata,
  });

  /// Creates a GarageModel from a JSON map
  factory GarageModel.fromJson(Map<String, dynamic> json) {
    return GarageModel(
      id: json['id'] as String,
      vehicleType: json['vehicleType'] as String,
      registrationNumber: json['registrationNumber'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      insuranceProvider: json['insuranceProvider'] as String?,
      policyNumber: json['policyNumber'] as String?,
      insuranceStartDate: json['insuranceStartDate'] != null
          ? DateTime.parse(json['insuranceStartDate'] as String)
          : null,
      insuranceEndDate: json['insuranceEndDate'] != null
          ? DateTime.parse(json['insuranceEndDate'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts GarageModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'registrationNumber': registrationNumber,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'insuranceProvider': insuranceProvider,
      'policyNumber': policyNumber,
      'insuranceStartDate': insuranceStartDate?.toIso8601String(),
      'insuranceEndDate': insuranceEndDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Creates a GarageModel from a domain Garage entity
  factory GarageModel.fromEntity(Garage garage) {
    return GarageModel(
      id: garage.id,
      vehicleType: garage.vehicleType,
      registrationNumber: garage.registrationNumber,
      make: garage.make,
      model: garage.model,
      year: garage.year,
      color: garage.color,
      insuranceProvider: garage.insuranceProvider,
      policyNumber: garage.policyNumber,
      insuranceStartDate: garage.insuranceStartDate,
      insuranceEndDate: garage.insuranceEndDate,
      imageUrl: garage.imageUrl,
      notes: garage.notes,
      metadata: garage.metadata,
    );
  }
}

