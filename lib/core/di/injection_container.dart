import 'package:get_it/get_it.dart';
import '../../features/insurance/data/repositories/insurance_repository_impl.dart';
import '../../features/insurance/domain/repositories/insurance_repository.dart';
import '../../features/insurance/domain/usecases/add_insurance.dart';
import '../../features/insurance/domain/usecases/get_insurance_detail.dart';
import '../../features/insurance/domain/usecases/get_insurances.dart';
import '../../features/insurance/presentation/bloc/insurance_detail_cubit.dart';
import '../../features/insurance/presentation/bloc/insurance_list_cubit.dart';
import '../../features/insurance/presentation/bloc/insurance_selection_cubit.dart';
import '../services/user_preferences_service.dart';

/// Service locator instance for dependency injection
final sl = GetIt.instance;

/// Sets up dependency injection for the entire application
/// Registers all repositories, use cases, and BLoC/Cubits
Future<void> setupDependencyInjection() async {
  // ============================================================================
  // Services
  // ============================================================================
  sl.registerLazySingleton<UserPreferencesService>(
    () => UserPreferencesService(),
  );

  // ============================================================================
  // Repositories
  // ============================================================================
  sl.registerLazySingleton<InsuranceRepository>(
    () => InsuranceRepositoryImpl(),
  );

  // ============================================================================
  // Use Cases
  // ============================================================================
  sl.registerLazySingleton(() => GetInsurances(sl()));
  sl.registerLazySingleton(() => GetInsuranceDetail(sl()));
  sl.registerLazySingleton(() => AddInsurance(sl()));

  // ============================================================================
  // BLoC / Cubits
  // ============================================================================
  sl.registerFactory(
    () => InsuranceListCubit(sl()),
  );
  sl.registerFactory(
    () => InsuranceDetailCubit(sl()),
  );
  sl.registerFactory(
    () => InsuranceSelectionCubit(),
  );
}
