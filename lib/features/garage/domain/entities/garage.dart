import 'package:equatable/equatable.dart';

/// Garage entity representing a vehicle in the garage
/// This is a pure domain entity with no Flutter dependencies
class Garage extends Equatable {
  final String id;
  final String vehicleType; // "Car" or "Bike"
  final String registrationNumber;
  final String? make; // e.g., "Honda", "Toyota"
  final String? model; // e.g., "Civic", "City"
  final int? year;
  final String? color;
  final String? insuranceProvider;
  final String? policyNumber;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceEndDate;
  final String? imageUrl;
  final String? notes;
  final Map<String, dynamic>? metadata; // Additional flexible data

  const Garage({
    required this.id,
    required this.vehicleType,
    required this.registrationNumber,
    this.make,
    this.model,
    this.year,
    this.color,
    this.insuranceProvider,
    this.policyNumber,
    this.insuranceStartDate,
    this.insuranceEndDate,
    this.imageUrl,
    this.notes,
    this.metadata,
  });

  /// Returns true if the insurance is expiring within 30 days
  bool get isInsuranceExpiringSoon {
    if (insuranceEndDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = insuranceEndDate!.difference(now).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Returns true if the insurance has expired
  bool get isInsuranceExpired {
    if (insuranceEndDate == null) return false;
    return insuranceEndDate!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        vehicleType,
        registrationNumber,
        make,
        model,
        year,
        color,
        insuranceProvider,
        policyNumber,
        insuranceStartDate,
        insuranceEndDate,
        imageUrl,
        notes,
        metadata,
      ];
}

