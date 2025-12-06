import 'package:equatable/equatable.dart';
import '../../domain/entities/insurance.dart';

/// Base class for search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state when search page is first loaded
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// State when search is in progress
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// State when search has completed successfully
class SearchLoaded extends SearchState {
  final List<Insurance> results;
  final String query;

  const SearchLoaded({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// State when search has no results
class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

/// State when search encounters an error
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}


