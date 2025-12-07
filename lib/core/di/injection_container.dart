import 'package:get_it/get_it.dart';
import '../../features/insurance/data/repositories/insurance_repository_impl.dart';
import '../../features/insurance/domain/repositories/insurance_repository.dart';
import '../../features/insurance/domain/usecases/add_insurance.dart';
import '../../features/insurance/domain/usecases/get_insurance_detail.dart';
import '../../features/insurance/domain/usecases/get_insurances.dart';
import '../../features/insurance/domain/usecases/search_insurances.dart';
import '../../features/insurance/presentation/bloc/insurance_list_cubit.dart';
import '../../features/insurance/presentation/bloc/insurance_detail_cubit.dart';
import '../../features/insurance/presentation/bloc/insurance_selection_cubit.dart';
import '../../features/insurance/presentation/bloc/search_cubit.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../services/groq_chat_service.dart';
import '../services/notification_service.dart';
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
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl()),
  );
  sl.registerLazySingleton<GroqChatService>(
    () => GroqChatService(),
  );

  // ============================================================================
  // Repositories
  // ============================================================================
  sl.registerLazySingleton<InsuranceRepository>(
    () => InsuranceRepositoryImpl(),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

  // ============================================================================
  // Use Cases
  // ============================================================================
  sl.registerLazySingleton(() => GetInsurances(sl()));
  sl.registerLazySingleton(() => GetInsuranceDetail(sl()));
  sl.registerLazySingleton(() => AddInsurance(sl()));
  sl.registerLazySingleton(() => SearchInsurances(sl()));

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
  sl.registerFactory(
    () => SearchCubit(sl()),
  );
  sl.registerFactory(
    () => NotificationsCubit(sl()),
  );
}
