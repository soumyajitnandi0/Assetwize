import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_realties.dart';
import 'realty_list_state.dart';

/// Cubit for managing realty list state
class RealtyListCubit extends Cubit<RealtyListState> {
  final GetRealties _getRealties;

  RealtyListCubit(this._getRealties) : super(const RealtyListInitial());

  /// Loads all realty properties
  Future<void> loadRealties() async {
    emit(const RealtyListLoading());
    try {
      final realties = await _getRealties();
      emit(RealtyListLoaded(realties));
      logger.Logger.info('RealtyListCubit: Loaded ${realties.length} properties');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'RealtyListCubit: Failed to load realty',
        e,
        stackTrace,
      );
      emit(RealtyListError('Failed to load properties: ${e.toString()}'));
    }
  }

  /// Retries loading realty
  Future<void> retry() async {
    await loadRealties();
  }
}

