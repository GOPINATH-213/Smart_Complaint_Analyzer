import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';

/// Modern Enterprise Theme System for Smart Complaint Analyzer
class AppTheme {
  // Backwards-compatible constants
  static const Color slateNavyDark = AppColorsPalette.primaryNavy;
  static const Color slateNavyPrimary = AppColorsPalette.primaryNavyLight;
  static const Color royalBlue = AppColorsPalette.primaryAction;
  static const Color emeraldGreen = AppColorsPalette.success;
  static const Color lightBg = AppColorsPalette.background;
  static const Color cardBorderLight = AppColorsPalette.border;

  static const Color darkBg = AppColorsPalette.darkBackground;
  static const Color darkSurface = AppColorsPalette.darkSurface;
  static const Color cardBorderDark = AppColorsPalette.darkBorder;

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppColorsExtension.light],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsPalette.primaryNavy,
        brightness: Brightness.light,
        primary: AppColorsPalette.primaryNavy,
        secondary: AppColorsPalette.primaryAction,
        tertiary: AppColorsPalette.aiAccent,
        surface: AppColorsPalette.surface,
        onSurface: AppColorsPalette.textPrimary,
        surfaceContainerLow: AppColorsPalette.surface,
        outlineVariant: AppColorsPalette.border,
        error: AppColorsPalette.error,
      ),
      scaffoldBackgroundColor: AppColorsPalette.background,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColorsPalette.textPrimary,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColorsPalette.textPrimary,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColorsPalette.textPrimary,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        titleSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColorsPalette.textPrimary,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColorsPalette.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColorsPalette.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColorsPalette.textSecondary,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsPalette.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColorsPalette.primaryNavy),
        titleTextStyle: GoogleFonts.inter(
          color: AppColorsPalette.primaryNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColorsPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r14,
          side: const BorderSide(color: AppColorsPalette.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsPalette.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.primaryAction, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColorsPalette.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColorsPalette.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsPalette.primaryAction,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r12,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsPalette.primaryNavy,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r12,
          ),
          side: const BorderSide(color: AppColorsPalette.border, width: 1.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsPalette.primaryAction,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsPalette.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsPalette.surfaceSecondary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppColorsExtension.dark],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsPalette.darkPrimaryAction,
        brightness: Brightness.dark,
        primary: AppColorsPalette.darkPrimaryAction,
        secondary: AppColorsPalette.darkAiAccent,
        surface: AppColorsPalette.darkBackground,
        onSurface: AppColorsPalette.darkTextPrimary,
        surfaceContainerLow: AppColorsPalette.darkSurface,
        outlineVariant: AppColorsPalette.darkBorder,
        error: AppColorsPalette.darkError,
      ),
      scaffoldBackgroundColor: AppColorsPalette.darkBackground,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColorsPalette.darkTextPrimary,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColorsPalette.darkTextPrimary,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColorsPalette.darkTextPrimary,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        titleSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColorsPalette.darkTextPrimary,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColorsPalette.darkTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColorsPalette.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColorsPalette.darkTextSecondary,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsPalette.darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColorsPalette.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r14,
          side: const BorderSide(color: AppColorsPalette.darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsPalette.darkSurface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.darkPrimaryAction, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r12,
          borderSide: const BorderSide(color: AppColorsPalette.darkError, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColorsPalette.darkTextMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColorsPalette.darkTextSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsPalette.darkPrimaryAction,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r12,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsPalette.darkTextPrimary,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.r12,
          ),
          side: const BorderSide(color: AppColorsPalette.darkBorder, width: 1.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsPalette.darkPrimaryAction,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsPalette.darkBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsPalette.darkSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.r8),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(color: AppColorsPalette.darkTextPrimary, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
