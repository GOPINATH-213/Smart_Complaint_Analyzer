import 'package:flutter/material.dart';

/// Centralized Enterprise Color Palette for Smart Complaint Analyzer
class AppColorsPalette {
  // Brand Structural Colors
  static const Color primaryNavy = Color(0xFF0F172A); // Deep Navy Blue
  static const Color primaryNavyLight = Color(0xFF1E293B); // Slate Navy
  static const Color primaryAction = Color(0xFF2563EB); // Professional Blue
  static const Color primaryActionHover = Color(0xFF1D4ED8);
  static const Color aiAccent = Color(0xFF06B6D4); // Cyan AI Accent
  static const Color aiAccentLight = Color(0xFFE0F2FE); // Soft Light Cyan/Blue
  static const Color aiAccentSubtle = Color(0xFFECFEFF);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocused = Color(0xFF2563EB);

  // Semantics
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Dark Theme Palette Foundation
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderLight = Color(0xFF475569);
  
  static const Color darkPrimaryAction = Color(0xFF3B82F6);
  static const Color darkAiAccent = Color(0xFF22D3EE);
  
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkTextInverse = Color(0xFF0F172A);
  
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkSuccessLight = Color(0xFF064E3B);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkWarningLight = Color(0xFF78350F);
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkErrorLight = Color(0xFF7F1D1D);
  static const Color darkInfo = Color(0xFF38BDF8);
  static const Color darkInfoLight = Color(0xFF0C4A6E);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryNavy;
  final Color primaryNavyLight;
  final Color primaryAction;
  final Color primaryActionHover;
  final Color aiAccent;
  final Color aiAccentLight;
  final Color aiAccentSubtle;

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSecondary;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;

  final Color border;
  final Color borderLight;
  final Color borderFocused;

  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color error;
  final Color errorLight;
  final Color info;
  final Color infoLight;

  const AppColorsExtension({
    required this.primaryNavy,
    required this.primaryNavyLight,
    required this.primaryAction,
    required this.primaryActionHover,
    required this.aiAccent,
    required this.aiAccentLight,
    required this.aiAccentSubtle,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.border,
    required this.borderLight,
    required this.borderFocused,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.info,
    required this.infoLight,
  });

  static const light = AppColorsExtension(
    primaryNavy: AppColorsPalette.primaryNavy,
    primaryNavyLight: AppColorsPalette.primaryNavyLight,
    primaryAction: AppColorsPalette.primaryAction,
    primaryActionHover: AppColorsPalette.primaryActionHover,
    aiAccent: AppColorsPalette.aiAccent,
    aiAccentLight: AppColorsPalette.aiAccentLight,
    aiAccentSubtle: AppColorsPalette.aiAccentSubtle,
    background: AppColorsPalette.background,
    surface: AppColorsPalette.surface,
    surfaceElevated: AppColorsPalette.surface,
    surfaceSecondary: AppColorsPalette.surfaceSecondary,
    textPrimary: AppColorsPalette.textPrimary,
    textSecondary: AppColorsPalette.textSecondary,
    textMuted: AppColorsPalette.textMuted,
    textInverse: AppColorsPalette.textInverse,
    border: AppColorsPalette.border,
    borderLight: AppColorsPalette.borderLight,
    borderFocused: AppColorsPalette.borderFocused,
    success: AppColorsPalette.success,
    successLight: AppColorsPalette.successLight,
    warning: AppColorsPalette.warning,
    warningLight: AppColorsPalette.warningLight,
    error: AppColorsPalette.error,
    errorLight: AppColorsPalette.errorLight,
    info: AppColorsPalette.info,
    infoLight: AppColorsPalette.infoLight,
  );

  static const dark = AppColorsExtension(
    primaryNavy: AppColorsPalette.darkSurfaceElevated, 
    primaryNavyLight: AppColorsPalette.darkBorder,
    primaryAction: AppColorsPalette.darkPrimaryAction,
    primaryActionHover: AppColorsPalette.primaryAction,
    aiAccent: AppColorsPalette.darkAiAccent,
    aiAccentLight: Color(0xFF164E63),
    aiAccentSubtle: Color(0xFF083344),
    background: AppColorsPalette.darkBackground,
    surface: AppColorsPalette.darkSurface,
    surfaceElevated: AppColorsPalette.darkSurfaceElevated,
    surfaceSecondary: AppColorsPalette.darkBorder,
    textPrimary: AppColorsPalette.darkTextPrimary,
    textSecondary: AppColorsPalette.darkTextSecondary,
    textMuted: AppColorsPalette.darkTextMuted,
    textInverse: Colors.white,
    border: AppColorsPalette.darkBorder,
    borderLight: AppColorsPalette.darkBorderLight,
    borderFocused: AppColorsPalette.darkPrimaryAction,
    success: AppColorsPalette.darkSuccess,
    successLight: AppColorsPalette.darkSuccessLight,
    warning: AppColorsPalette.darkWarning,
    warningLight: AppColorsPalette.darkWarningLight,
    error: AppColorsPalette.darkError,
    errorLight: AppColorsPalette.darkErrorLight,
    info: AppColorsPalette.darkInfo,
    infoLight: AppColorsPalette.darkInfoLight,
  );

  @override
  AppColorsExtension copyWith({
    Color? primaryNavy,
    Color? primaryNavyLight,
    Color? primaryAction,
    Color? primaryActionHover,
    Color? aiAccent,
    Color? aiAccentLight,
    Color? aiAccentSubtle,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? border,
    Color? borderLight,
    Color? borderFocused,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? error,
    Color? errorLight,
    Color? info,
    Color? infoLight,
  }) {
    return AppColorsExtension(
      primaryNavy: primaryNavy ?? this.primaryNavy,
      primaryNavyLight: primaryNavyLight ?? this.primaryNavyLight,
      primaryAction: primaryAction ?? this.primaryAction,
      primaryActionHover: primaryActionHover ?? this.primaryActionHover,
      aiAccent: aiAccent ?? this.aiAccent,
      aiAccentLight: aiAccentLight ?? this.aiAccentLight,
      aiAccentSubtle: aiAccentSubtle ?? this.aiAccentSubtle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderFocused: borderFocused ?? this.borderFocused,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryNavy: Color.lerp(primaryNavy, other.primaryNavy, t)!,
      primaryNavyLight: Color.lerp(primaryNavyLight, other.primaryNavyLight, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      primaryActionHover: Color.lerp(primaryActionHover, other.primaryActionHover, t)!,
      aiAccent: Color.lerp(aiAccent, other.aiAccent, t)!,
      aiAccentLight: Color.lerp(aiAccentLight, other.aiAccentLight, t)!,
      aiAccentSubtle: Color.lerp(aiAccentSubtle, other.aiAccentSubtle, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
    );
  }

  // Status Colors (Consistent semantics)
  Color getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'submitted':
        return primaryAction; // Blue
      case 'in progress':
        return warning; // Amber
      case 'resolved':
        return success; // Green
      case 'closed':
        return textSecondary; // Slate
      default:
        return primaryAction;
    }
  }

  Color getStatusLightColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'submitted':
        return infoLight;
      case 'in progress':
        return warningLight;
      case 'resolved':
        return successLight;
      case 'closed':
        return surfaceSecondary;
      default:
        return infoLight;
    }
  }

  // Priority Colors
  Color getPriorityColor(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return error;
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return textSecondary;
    }
  }

  Color getPriorityLightColor(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return errorLight;
      case 'medium':
        return warningLight;
      case 'low':
        return successLight;
      default:
        return surfaceSecondary;
    }
  }

  // Urgency Colors
  Color getUrgencyColor(String urgency) {
    switch (urgency.trim().toLowerCase()) {
      case 'critical':
        return error;
      case 'high':
        return const Color(0xFFEA580C); // Deep Orange
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return textSecondary;
    }
  }

  // Sentiment Colors
  Color getSentimentColor(String sentiment) {
    switch (sentiment.trim().toLowerCase()) {
      case 'positive':
        return success;
      case 'neutral':
        return info;
      case 'negative':
        return const Color(0xFFEA580C);
      case 'angry':
      case 'frustrated':
        return error;
      default:
        return textSecondary;
    }
  }

  // AI Status Colors
  Color getAiStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return success;
      case 'processing':
        return aiAccent;
      case 'failed':
        return error;
      case 'pending':
      default:
        return info;
    }
  }
}

extension AppColorsContextExtension on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
