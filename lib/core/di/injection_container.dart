import 'package:get_it/get_it.dart';
import '../../features/garage/data/repositories/garage_repository_impl.dart';
import '../../features/garage/domain/repositories/garage_repository.dart';
import '../../features/garage/domain/usecases/add_garage.dart';
import '../../features/garage/domain/usecases/get_garage_detail.dart';
import '../../features/garage/domain/usecases/get_garages.dart';
import '../../features/garage/presentation/bloc/garage_detail_cubit.dart';
import '../../features/garage/presentation/bloc/garage_list_cubit.dart';
import '../../features/garage/presentation/bloc/garage_selection_cubit.dart';
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
import '../../features/notifications/domain/usecases/add_notification.dart';
import '../../features/notifications/domain/usecases/delete_notification.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/get_unread_count.dart';
import '../../features/notifications/domain/usecases/mark_all_as_read.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read.dart';
import '../../features/notifications/domain/usecases/notify_asset_added.dart';
import '../../features/notifications/domain/usecases/notify_profile_updated.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/check_first_launch.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/clear_profile.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_email.dart';
import '../../features/profile/domain/usecases/update_name.dart';
import '../../features/profile/domain/usecases/update_phone_number.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
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
    () => NotificationService(
      sl<GetUnreadCount>(),
      sl<NotifyAssetAdded>(),
      sl<NotifyProfileUpdated>(),
    ),
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
  sl.registerLazySingleton<GarageRepository>(
    () => GarageRepositoryImpl(),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(),
  );

  // ============================================================================
  // Use Cases
  // ============================================================================
  // Insurance use cases
  sl.registerLazySingleton(() => GetInsurances(sl()));
  sl.registerLazySingleton(() => GetInsuranceDetail(sl()));
  sl.registerLazySingleton(() => AddInsurance(sl()));
  sl.registerLazySingleton(() => SearchInsurances(sl()));
  
  // Garage use cases
  sl.registerLazySingleton(() => GetGarages(sl()));
  sl.registerLazySingleton(() => GetGarageDetail(sl()));
  sl.registerLazySingleton(() => AddGarage(sl()));
  
  // Notification use cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetUnreadCount(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllAsRead(sl()));
  sl.registerLazySingleton(() => AddNotification(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));
  sl.registerLazySingleton(() => NotifyAssetAdded(sl()));
  sl.registerLazySingleton(() => NotifyProfileUpdated(sl()));
  
  // Profile use cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UpdateName(sl()));
  sl.registerLazySingleton(() => UpdatePhoneNumber(sl()));
  sl.registerLazySingleton(() => UpdateEmail(sl()));
  sl.registerLazySingleton(() => ClearProfile(sl()));
  
  // Onboarding use cases
  sl.registerLazySingleton(() => CheckFirstLaunch(sl()));
  sl.registerLazySingleton(() => CompleteOnboarding(sl()));

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
    () => GarageListCubit(sl()),
  );
  sl.registerFactory(
    () => GarageDetailCubit(sl()),
  );
  sl.registerFactory(
    () => GarageSelectionCubit(),
  );
  sl.registerFactory(
    () => NotificationsCubit(
      sl<GetNotifications>(),
      sl<MarkNotificationAsRead>(),
      sl<MarkAllAsRead>(),
      sl<DeleteNotification>(),
    ),
  );
}
