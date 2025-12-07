import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_jewellery_detail.dart';
import 'jewellery_detail_state.dart';

/// Cubit for managing jewellery detail state
class JewelleryDetailCubit extends Cubit<JewelleryDetailState> {
  final GetJewelleryDetail getJewelleryDetail;

  JewelleryDetailCubit(this.getJewelleryDetail) : super(const JewelleryDetailInitial());

  /// Loads a single jewellery by ID
  Future<void> loadJewellery(String id) async {
    if (id.isEmpty) {
      const errorMessage = 'Jewellery ID cannot be empty';
      emit(const JewelleryDetailError(errorMessage));
      return;
    }

    if (state is JewelleryDetailLoading) {
      logger.Logger.debug('JewelleryDetailCubit: Already loading, skipping request');
      return;
    }

    emit(const JewelleryDetailLoading());
    logger.Logger.debug('JewelleryDetailCubit: Loading jewellery...');

    try {
      final jewellery = await getJewelleryDetail(id);
      emit(JewelleryDetailLoaded(jewellery));
      logger.Logger.info('JewelleryDetailCubit: Successfully loaded jewellery ${jewellery.id}');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(JewelleryDetailError(errorMessage));
      logger.Logger.error(
        'JewelleryDetailCubit: Failed to load jewellery',
        e,
        stackTrace,
      );
    }
  }

  /// Retries loading jewellery after an error
  Future<void> retry(String id) async {
    logger.Logger.debug('JewelleryDetailCubit: Retrying load...');
    await loadJewellery(id);
  }

  /// Extracts a user-friendly error message from an exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    if (errorString.isEmpty) {
      return 'Failed to load jewellery details. Please try again.';
    }
    return errorString;
  }
}

