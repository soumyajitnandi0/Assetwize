import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

/// States for unified search across all assets
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no search performed yet
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state - search is in progress
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Loaded state - search completed with results
class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final String query;

  const SearchLoaded({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// Empty state - search completed but no results found
class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Error state - search failed
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

