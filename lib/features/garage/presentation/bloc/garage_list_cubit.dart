import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_garages.dart';
import 'garage_list_state.dart';

/// Cubit for managing garage list state
class GarageListCubit extends Cubit<GarageListState> {
  final GetGarages _getGarages;

  GarageListCubit(this._getGarages) : super(const GarageListInitial());

  /// Loads all vehicles from the garage
  Future<void> loadGarages() async {
    emit(const GarageListLoading());
    try {
      final garages = await _getGarages();
      emit(GarageListLoaded(garages));
      logger.Logger.info('GarageListCubit: Loaded ${garages.length} vehicles');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageListCubit: Failed to load garages',
        e,
        stackTrace,
      );
      emit(GarageListError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  /// Retries loading garages
  Future<void> retry() async {
    await loadGarages();
  }
}

