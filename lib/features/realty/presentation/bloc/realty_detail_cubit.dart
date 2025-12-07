import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_realty_detail.dart';
import 'realty_detail_state.dart';

/// Cubit for managing realty detail state
class RealtyDetailCubit extends Cubit<RealtyDetailState> {
  final GetRealtyDetail getRealtyDetail;

  RealtyDetailCubit(this.getRealtyDetail) : super(const RealtyDetailInitial());

  /// Loads a single realty property by ID
  Future<void> loadRealty(String id) async {
    if (id.isEmpty) {
      const errorMessage = 'Realty ID cannot be empty';
      emit(const RealtyDetailError(errorMessage));
      return;
    }

    if (state is RealtyDetailLoading) {
      logger.Logger.debug('RealtyDetailCubit: Already loading, skipping request');
      return;
    }

    emit(const RealtyDetailLoading());
    logger.Logger.debug('RealtyDetailCubit: Loading realty...');

    try {
      final realty = await getRealtyDetail(id);
      emit(RealtyDetailLoaded(realty));
      logger.Logger.info('RealtyDetailCubit: Successfully loaded realty ${realty.id}');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(RealtyDetailError(errorMessage));
      logger.Logger.error(
        'RealtyDetailCubit: Failed to load realty',
        e,
        stackTrace,
      );
    }
  }

  /// Retries loading realty after an error
  Future<void> retry(String id) async {
    logger.Logger.debug('RealtyDetailCubit: Retrying load...');
    await loadRealty(id);
  }

  /// Extracts a user-friendly error message from an exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    if (errorString.isEmpty) {
      return 'Failed to load property details. Please try again.';
    }
    return errorString;
  }
}

