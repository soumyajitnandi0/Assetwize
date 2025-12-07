import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart' as logger;
import 'core/widgets/error_boundary.dart';
import 'features/insurance/presentation/bloc/insurance_list_cubit.dart';
import 'features/onboarding/domain/usecases/check_first_launch.dart';
import 'core/navigation/main_navigator.dart';
import 'features/onboarding/presentation/pages/welcome_page.dart';

/// Application entry point
///
/// Initializes dependency injection, system configurations,
/// and error handling before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    logger.Logger.info('Environment variables loaded successfully');
  } catch (e, stackTrace) {
    logger.Logger.warning(
      'Failed to load .env file. Some features may not work without API keys.',
      e,
      stackTrace,
    );
    // Continue anyway - app can still run without some API keys
  }

  // Setup error handling for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.Logger.error(
      'Flutter framework error',
      details.exception,
      details.stack,
    );
    // In production, send to crash reporting service
    // FlutterError.presentError(details);
  };

  // Setup Dependency Injection
  try {
    await setupDependencyInjection();
    logger.Logger.info('Dependency injection setup completed');
  } catch (e, stackTrace) {
    logger.Logger.error(
      'Failed to setup dependency injection',
      e,
      stackTrace,
    );
    // Continue anyway - some dependencies might still work
  }

  // Preload Montserrat font to ensure it's available on mobile
  // This ensures the font is downloaded and cached before the app renders
  try {
    // Preload the font by creating a TextStyle - this triggers font download
    // The font will be cached after first download for offline use
    GoogleFonts.montserrat();
    logger.Logger.info('Montserrat font preload initiated');
  } catch (e, stackTrace) {
    logger.Logger.warning(
      'Failed to preload Montserrat font, will use fallback',
      e,
      stackTrace,
    );
    // Continue anyway - GoogleFonts will handle fallback
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Run app with error boundary
  runApp(const AssetwizeApp());
}

/// Root application widget
///
/// Wraps the app with error boundary and BLoC providers.
/// Provides global error handling and state management setup.
/// Shows welcome page for first-time users, otherwise shows main app.
class AssetwizeApp extends StatefulWidget {
  const AssetwizeApp({super.key});

  @override
  State<AssetwizeApp> createState() => _AssetwizeAppState();
}

class _AssetwizeAppState extends State<AssetwizeApp> {
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final checkFirstLaunch = sl<CheckFirstLaunch>();
      final isFirst = await checkFirstLaunch();
      if (mounted) {
        setState(() {
          _isFirstLaunch = isFirst;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to check first launch status',
        e,
        stackTrace,
      );
      // Default to showing welcome page if check fails
      if (mounted) {
        setState(() {
          _isFirstLaunch = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ErrorBoundary(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              final cubit = sl<InsuranceListCubit>();
              // Don't load here - let InsuranceListPage handle it
              // This ensures data loads when navigating from welcome page
              return cubit;
            },
          ),
        ],
        child: MaterialApp(
          title: 'ASSETWIZE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: _isFirstLaunch ? const WelcomePage() : const MainNavigator(),
          routes: {
            '/home': (context) => const MainNavigator(),
          },
          // Global error handling for routes
          builder: (context, child) {
            return ErrorBoundary(child: child ?? const SizedBox.shrink());
          },
        ),
      ),
    );
  }
}
