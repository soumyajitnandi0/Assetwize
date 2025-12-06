/// Application-wide constants for consistent UI and configuration
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ============================================================================
  // SPACING
  // ============================================================================
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 20.0; // Main padding (20px)
  static const double spacingXL = 24.0; // Card spacing (24px)
  static const double spacingXXL = 32.0;
  static const double spacingXXXL = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0; // Main corner radius for cards (20px)
  static const double radiusXXL = 24.0;

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================
  static const double cardImageHeight = 180.0;
  static const double cardElevation = 2.0;

  // ============================================================================
  // GRID LAYOUT
  // ============================================================================
  static const int gridCrossAxisCountMobile = 1;
  static const int gridCrossAxisCountTablet = 2;
  static const int gridCrossAxisCountDesktop = 3;
  static const double gridChildAspectRatio = 0.85;
  static const double gridSpacing = 16.0;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // BREAKPOINTS
  // ============================================================================
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // ============================================================================
  // IMAGE CACHE
  // ============================================================================
  static const int maxCacheSize = 100;
  static const int maxCacheAge = 7; // days

  // ============================================================================
  // NETWORK
  // ============================================================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
}
