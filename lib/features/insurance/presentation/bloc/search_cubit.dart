import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/search_insurances.dart';
import 'search_state.dart';

/// Cubit for managing search state
///
/// Handles searching insurance policies with debouncing and state management.
/// Follows BLoC pattern for predictable state management.
///
/// This cubit is responsible for:
/// - Searching insurance policies by query
/// - Managing loading, success, empty, and error states
/// - Providing real-time search functionality
class SearchCubit extends Cubit<SearchState> {
  final SearchInsurances searchInsurances;

  SearchCubit(this.searchInsurances) : super(const SearchInitial());

  /// Performs a search with the given query
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
    logger.Logger.debug('SearchCubit: Searching for "$trimmedQuery"');

    try {
      final results = await searchInsurances(trimmedQuery);

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
        'SearchCubit: Failed to search insurances',
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


