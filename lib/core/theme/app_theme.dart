import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// App theme configuration matching Figma design
/// Uses green as primary color (matching ASSETWIZE branding)
class AppTheme {
  AppTheme._();

  // Color palette matching UI-2 design specifications
  static const Color primaryGreen = Color(0xFF065F46); // Dark green #065F46
  static const Color stepIndicatorGreen =
      Color(0xFF075E54); // Step indicator green #075E54
  static const Color headerTextColor = Color(0xFF1A1A1A); // Header text #1A1A1A
  static const Color disabledButtonBg =
      Color(0xFFEDEDED); // Disabled button #EDEDED
  static const Color primaryGreenLight = Color(0xFF4CAF50); // Light green
  static const Color accentYellow = Color(0xFFFFC107); // Yellow for CTAs
  static const Color textPrimary = Color(0xFF1C1C1E); // Text black #1C1C1E
  static const Color textSecondary = Color(0xFF8E8E93); // Subtext grey #8E8E93
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light grey
  static const Color cardBackground = Color(0xFFFFFFFF); // White
  static const Color borderColor = Color(0xFFE5E7EB); // Card border #E5E7EB
  static const Color cardBorderLight =
      Color(0xFFE6E6E6); // Light border #E6E6E6
  static const Color errorColor = Color(0xFFD32F2F); // Red for errors
  static const Color warningColor = Color(0xFFF57C00); // Orange for warnings

  static ThemeData get lightTheme {
    // Get Montserrat font with fallback to system font if loading fails
    final montserrat = GoogleFonts.montserrat();
    final fontFamily = montserrat.fontFamily ?? 'Roboto'; // Fallback to Roboto

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: primaryGreenLight,
        surface: cardBackground,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: montserrat.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
