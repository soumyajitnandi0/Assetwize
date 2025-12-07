import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/entities/garage.dart';
import '../../domain/repositories/garage_repository.dart';
import '../models/garage_model.dart';

/// Local implementation of GarageRepository using SharedPreferences
/// Stores garage data as JSON strings
class GarageRepositoryImpl implements GarageRepository {
  static const String _keyGarages = 'garages';

  @override
  Future<List<Garage>> getGarages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final garagesJson = prefs.getString(_keyGarages);

      if (garagesJson == null || garagesJson.isEmpty) {
        return [];
      }

      final List<dynamic> garagesList = json.decode(garagesJson);
      return garagesList
          .map((json) => GarageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageRepositoryImpl: Failed to get garages',
        e,
        stackTrace,
      );
      throw StorageException('Failed to load garage data: ${e.toString()}');
    }
  }

  @override
  Future<Garage> getGarage(String id) async {
    try {
      final garages = await getGarages();
      final garage = garages.firstWhere(
        (g) => g.id == id,
        orElse: () => throw NotFoundException('Garage with id $id not found'),
      );
      return garage;
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      logger.Logger.error(
        'GarageRepositoryImpl: Failed to get garage',
        e,
      );
      throw StorageException('Failed to load garage: ${e.toString()}');
    }
  }

  @override
  Future<void> addGarage(Garage garage) async {
    try {
      final garages = await getGarages();
      
      // Remove existing garage with same ID if updating
      final updatedGarages = garages.where((g) => g.id != garage.id).toList();
      updatedGarages.add(GarageModel.fromEntity(garage));

      final prefs = await SharedPreferences.getInstance();
      final garagesJson = json.encode(
        updatedGarages.map((g) => GarageModel.fromEntity(g).toJson()).toList(),
      );

      final success = await prefs.setString(_keyGarages, garagesJson);
      if (!success) {
        throw const StorageException('Failed to save garage data');
      }

      logger.Logger.info('GarageRepositoryImpl: Garage saved successfully');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageRepositoryImpl: Failed to add garage',
        e,
        stackTrace,
      );
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to save garage: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGarage(String id) async {
    try {
      final garages = await getGarages();
      final updatedGarages = garages.where((g) => g.id != id).toList();

      final prefs = await SharedPreferences.getInstance();
      if (updatedGarages.isEmpty) {
        await prefs.remove(_keyGarages);
      } else {
        final garagesJson = json.encode(
          updatedGarages
              .map((g) => GarageModel.fromEntity(g).toJson())
              .toList(),
        );
        await prefs.setString(_keyGarages, garagesJson);
      }

      logger.Logger.info('GarageRepositoryImpl: Garage deleted successfully');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageRepositoryImpl: Failed to delete garage',
        e,
        stackTrace,
      );
      throw StorageException('Failed to delete garage: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGarages);
      logger.Logger.info('GarageRepositoryImpl: All garage data cleared');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageRepositoryImpl: Failed to clear all garages',
        e,
        stackTrace,
      );
      throw StorageException('Failed to clear garage data: ${e.toString()}');
    }
  }
}

