import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/jewellery.dart';
import '../../domain/repositories/jewellery_repository.dart';
import '../models/jewellery_model.dart';

/// Local implementation of JewelleryRepository
///
/// Uses SharedPreferences for persistent local storage.
class JewelleryRepositoryImpl implements JewelleryRepository {
  static const String _storageKey = 'jewelleries';

  /// Loads jewellery items from SharedPreferences
  Future<List<JewelleryModel>> _loadJewelleries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);

      if (storedJson == null || storedJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(storedJson) as List<dynamic>;
      return jsonList
          .map((json) => JewelleryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to load jewellery items: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Saves jewellery items to SharedPreferences
  Future<void> _saveJewelleries(List<JewelleryModel> jewelleries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = jewelleries.map((j) => j.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to save jewellery items: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Jewellery>> getJewelleries() async {
    return await _loadJewelleries();
  }

  @override
  Future<Jewellery> getJewellery(String id) async {
    final jewelleries = await _loadJewelleries();
    try {
      return jewelleries.firstWhere((j) => j.id == id);
    } catch (e) {
      throw NotFoundException('Jewellery item with ID $id not found');
    }
  }

  @override
  Future<void> addJewellery(Jewellery jewellery) async {
    final jewelleries = await _loadJewelleries();
    final model = JewelleryModel.fromEntity(jewellery);

    // Check if item exists (update) or add new
    final index = jewelleries.indexWhere((j) => j.id == jewellery.id);
    if (index >= 0) {
      jewelleries[index] = model;
    } else {
      jewelleries.add(model);
    }

    await _saveJewelleries(jewelleries);
  }

  @override
  Future<void> deleteJewellery(String id) async {
    final jewelleries = await _loadJewelleries();
    jewelleries.removeWhere((j) => j.id == id);
    await _saveJewelleries(jewelleries);
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to clear jewellery data: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

