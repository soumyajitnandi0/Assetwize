import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/insurance.dart';
import '../../domain/repositories/insurance_repository.dart';
import '../models/insurance_model.dart';

/// Local implementation of InsuranceRepository
///
/// Uses SharedPreferences for persistent local storage.
/// This implementation provides a simple, local-first data storage solution.
///
/// For production use with cloud sync, consider implementing
/// a Firestore-based repository.
class InsuranceRepositoryImpl implements InsuranceRepository {
  static const String _storageKey = 'insurances';

  /// Loads insurances from SharedPreferences
  ///
  /// Returns an empty list if no data is stored.
  /// Throws an exception if data corruption is detected.
  Future<List<InsuranceModel>> _loadInsurances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);

      if (storedJson == null || storedJson.isEmpty) {
        return [];
      }

      final List<dynamic> storedList = json.decode(storedJson) as List<dynamic>;
      return storedList
          .map((json) => InsuranceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw Exception('Failed to parse stored insurance data');
    } catch (e) {
      throw Exception('Failed to load insurances: ${e.toString()}');
    }
  }

  /// Saves insurances to SharedPreferences
  ///
  /// Throws an exception if the save operation fails.
  Future<void> _saveInsurances(List<InsuranceModel> insurances) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = insurances.map((i) => i.toJson()).toList();
      final success = await prefs.setString(_storageKey, json.encode(jsonList));

      if (!success) {
        throw Exception('Failed to save insurances to storage');
      }
    } catch (e) {
      throw Exception('Failed to save insurances: ${e.toString()}');
    }
  }

  @override
  Future<List<Insurance>> getInsurances() async {
    try {
      final insurances = await _loadInsurances();
      return List<Insurance>.from(insurances);
    } catch (e) {
      throw Exception('Failed to fetch insurances: ${e.toString()}');
    }
  }

  @override
  Future<Insurance> getInsurance(String id) async {
    if (id.isEmpty) {
      throw Exception('Insurance ID cannot be empty');
    }

    try {
      final insurances = await _loadInsurances();
      final insurance = insurances.firstWhere(
        (insurance) => insurance.id == id,
        orElse: () => throw Exception('Insurance not found'),
      );
      return insurance;
    } catch (e) {
      if (e.toString().contains('not found')) {
        rethrow;
      }
      throw Exception('Failed to fetch insurance: ${e.toString()}');
    }
  }

  @override
  Future<void> addInsurance(Insurance insurance) async {
    try {
      final insurances = await _loadInsurances();
      final newInsurance = InsuranceModel.fromEntity(insurance);

      // Check if insurance with same ID already exists (update vs insert)
      final existingIndex = insurances.indexWhere((i) => i.id == insurance.id);
      if (existingIndex >= 0) {
        insurances[existingIndex] = newInsurance;
      } else {
        insurances.add(newInsurance);
      }

      await _saveInsurances(insurances);
    } catch (e) {
      throw Exception('Failed to save insurance: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_storageKey);
      
      if (!success) {
        throw Exception('Failed to clear insurance data');
      }
    } catch (e) {
      throw Exception('Failed to clear insurance data: ${e.toString()}');
    }
  }
}
