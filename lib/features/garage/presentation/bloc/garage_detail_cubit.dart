import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_garage_detail.dart';
import 'garage_detail_state.dart';

/// Cubit for managing garage detail state
///
/// Handles loading, success, and error states with retry logic.
/// Follows BLoC pattern for predictable state management.
class GarageDetailCubit extends Cubit<GarageDetailState> {
  final GetGarageDetail getGarageDetail;

  GarageDetailCubit(this.getGarageDetail) : super(const GarageDetailInitial());

  /// Loads a single garage by ID
  ///
  /// [id] - The unique identifier of the garage
  ///
  /// Emits [GarageDetailLoading] state first, then either:
  /// - [GarageDetailLoaded] with the garage on success
  /// - [GarageDetailError] with error message on failure
  Future<void> loadGarage(String id) async {
    if (id.isEmpty) {
      const errorMessage = 'Garage ID cannot be empty';
      emit(const GarageDetailError(errorMessage));
      return;
    }

    // Don't reload if already loading
    if (state is GarageDetailLoading) {
      logger.Logger.debug('GarageDetailCubit: Already loading, skipping request');
      return;
    }

    emit(const GarageDetailLoading());
    logger.Logger.debug('GarageDetailCubit: Loading garage...');

    try {
      final garage = await getGarageDetail(id);
      emit(GarageDetailLoaded(garage));
      logger.Logger.info('GarageDetailCubit: Successfully loaded garage ${garage.id}');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(GarageDetailError(errorMessage));
      logger.Logger.error(
        'GarageDetailCubit: Failed to load garage',
        e,
        stackTrace,
      );
    }
  }

  /// Retries loading garage after an error
  Future<void> retry(String id) async {
    logger.Logger.debug('GarageDetailCubit: Retrying load...');
    await loadGarage(id);
  }

  /// Extracts a user-friendly error message from an exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    // Return a generic message for unknown errors
    if (errorString.isEmpty) {
      return 'Failed to load vehicle details. Please try again.';
    }
    return errorString;
  }
}

