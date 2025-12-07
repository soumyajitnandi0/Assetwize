import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/search_all_assets.dart';
import 'search_state.dart';

/// Cubit for managing unified search state across all assets
///
/// Handles searching across Insurance, Garage, Jewellery, and Realty
/// with debouncing and state management.
/// Follows BLoC pattern for predictable state management.
class SearchCubit extends Cubit<SearchState> {
  final SearchAllAssets searchAllAssets;

  SearchCubit(this.searchAllAssets) : super(const SearchInitial());

  /// Performs a search across all asset types with the given query
  ///
  /// [query] - The search query string
  ///
  /// Emits [SearchLoading] state first, then either:
  /// - [SearchLoaded] with results if matches are found
  /// - [SearchEmpty] if no matches are found
  /// - [SearchError] with error message on failure
  ///
  /// If query is empty, emits [SearchInitial] state.
  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    // If query is empty, reset to initial state
    if (trimmedQuery.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());
    logger.Logger.debug('SearchCubit: Searching all assets for "$trimmedQuery"');

    try {
      final results = await searchAllAssets(trimmedQuery);

      if (results.isEmpty) {
        emit(SearchEmpty(query: trimmedQuery));
        logger.Logger.info(
            'SearchCubit: No results found for "$trimmedQuery"');
      } else {
        emit(SearchLoaded(results: results, query: trimmedQuery));
        logger.Logger.info(
            'SearchCubit: Found ${results.length} results for "$trimmedQuery"');
      }
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(SearchError(errorMessage));
      logger.Logger.error(
        'SearchCubit: Failed to search assets',
        e,
        stackTrace,
      );
    }
  }

  /// Clears the search and resets to initial state
  void clearSearch() {
    emit(const SearchInitial());
    logger.Logger.debug('SearchCubit: Search cleared');
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
      return 'Failed to search. Please try again.';
    }
    return errorString;
  }
}

