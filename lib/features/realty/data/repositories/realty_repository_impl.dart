import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/realty.dart';
import '../../domain/repositories/realty_repository.dart';
import '../models/realty_model.dart';

/// Local implementation of RealtyRepository
///
/// Uses SharedPreferences for persistent local storage.
class RealtyRepositoryImpl implements RealtyRepository {
  static const String _storageKey = 'realties';

  /// Loads realty properties from SharedPreferences
  Future<List<RealtyModel>> _loadRealties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);

      if (storedJson == null || storedJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(storedJson) as List<dynamic>;
      return jsonList
          .map((json) => RealtyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to load realty properties: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Saves realty properties to SharedPreferences
  Future<void> _saveRealties(List<RealtyModel> realties) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = realties.map((r) => r.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to save realty properties: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Realty>> getRealties() async {
    return await _loadRealties();
  }

  @override
  Future<Realty> getRealty(String id) async {
    final realties = await _loadRealties();
    try {
      return realties.firstWhere((r) => r.id == id);
    } catch (e) {
      throw NotFoundException('Realty property with ID $id not found');
    }
  }

  @override
  Future<void> addRealty(Realty realty) async {
    final realties = await _loadRealties();
    final model = RealtyModel.fromEntity(realty);

    // Check if property exists (update) or add new
    final index = realties.indexWhere((r) => r.id == realty.id);
    if (index >= 0) {
      realties[index] = model;
    } else {
      realties.add(model);
    }

    await _saveRealties(realties);
  }

  @override
  Future<void> deleteRealty(String id) async {
    final realties = await _loadRealties();
    realties.removeWhere((r) => r.id == id);
    await _saveRealties(realties);
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to clear realty data: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

