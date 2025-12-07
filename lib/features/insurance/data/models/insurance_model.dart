import '../../domain/entities/insurance.dart';

/// Insurance model extending the domain entity
/// Handles data serialization/deserialization
class InsuranceModel extends Insurance {
  const InsuranceModel({
    required super.id,
    required super.title,
    required super.provider,
    required super.policyNumber,
    required super.startDate,
    required super.endDate,
    required super.imageUrl,
    super.shortDescription,
    required super.type,
    super.coverage,
    super.metadata,
  });

  /// Creates an InsuranceModel from a JSON map
  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      policyNumber: json['policyNumber'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      imageUrl: json['imageUrl'] as String,
      shortDescription: json['shortDescription'] as String?,
      type: json['type'] as String,
      coverage: json['coverage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts InsuranceModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'policyNumber': policyNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
      'shortDescription': shortDescription,
      'type': type,
      'coverage': coverage,
      'metadata': metadata,
    };
  }

  /// Creates an InsuranceModel from a domain Insurance entity
  factory InsuranceModel.fromEntity(Insurance insurance) {
    return InsuranceModel(
      id: insurance.id,
      title: insurance.title,
      provider: insurance.provider,
      policyNumber: insurance.policyNumber,
      startDate: insurance.startDate,
      endDate: insurance.endDate,
      imageUrl: insurance.imageUrl,
      shortDescription: insurance.shortDescription,
      type: insurance.type,
      coverage: insurance.coverage,
      metadata: insurance.metadata,
    );
  }
}
