import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_jewelleries.dart';
import 'jewellery_list_state.dart';

/// Cubit for managing jewellery list state
class JewelleryListCubit extends Cubit<JewelleryListState> {
  final GetJewelleries _getJewelleries;

  JewelleryListCubit(this._getJewelleries) : super(const JewelleryListInitial());

  /// Loads all jewellery items
  Future<void> loadJewelleries() async {
    emit(const JewelleryListLoading());
    try {
      final jewelleries = await _getJewelleries();
      emit(JewelleryListLoaded(jewelleries));
      logger.Logger.info('JewelleryListCubit: Loaded ${jewelleries.length} items');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'JewelleryListCubit: Failed to load jewellery',
        e,
        stackTrace,
      );
      emit(JewelleryListError('Failed to load jewellery: ${e.toString()}'));
    }
  }

  /// Retries loading jewellery
  Future<void> retry() async {
    await loadJewelleries();
  }
}

