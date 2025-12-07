import 'package:equatable/equatable.dart';
import '../../domain/entities/garage.dart';

/// States for garage list
abstract class GarageListState extends Equatable {
  const GarageListState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class GarageListInitial extends GarageListState {
  const GarageListInitial();
}

/// Loading state - data is being fetched
class GarageListLoading extends GarageListState {
  const GarageListLoading();
}

/// Loaded state - data successfully fetched
class GarageListLoaded extends GarageListState {
  final List<Garage> garages;

  const GarageListLoaded(this.garages);

  @override
  List<Object?> get props => [garages];
}

/// Error state - data fetch failed
class GarageListError extends GarageListState {
  final String message;

  const GarageListError(this.message);

  @override
  List<Object?> get props => [message];
}

