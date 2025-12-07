import 'package:equatable/equatable.dart';
import '../../domain/entities/garage.dart';

/// States for GarageDetailCubit
abstract class GarageDetailState extends Equatable {
  const GarageDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class GarageDetailInitial extends GarageDetailState {
  const GarageDetailInitial();
}

/// Loading state - fetching data
class GarageDetailLoading extends GarageDetailState {
  const GarageDetailLoading();
}

/// Loaded state - data successfully fetched
class GarageDetailLoaded extends GarageDetailState {
  final Garage garage;

  const GarageDetailLoaded(this.garage);

  @override
  List<Object?> get props => [garage];
}

/// Error state - something went wrong
class GarageDetailError extends GarageDetailState {
  final String message;

  const GarageDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

