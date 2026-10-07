import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Enterprise Typography Scale using Inter Font
extension AppTextStylesExtension on BuildContext {
  TextStyle pageTitle({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color ?? colors.textPrimary,
        letterSpacing: -0.5,
        height: 1.25,
      );

  TextStyle pageSubtitle({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? colors.textSecondary,
        letterSpacing: -0.1,
        height: 1.4,
      );

  TextStyle sectionHeading({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color ?? colors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  TextStyle sectionSubheading({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color ?? colors.textSecondary,
        letterSpacing: -0.1,
        height: 1.3,
      );

  TextStyle cardTitle({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? colors.textPrimary,
        letterSpacing: -0.2,
        height: 1.35,
      );

  TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color ?? colors.textPrimary,
        height: 1.5,
      );

  TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? colors.textSecondary,
        height: 1.45,
      );

  TextStyle bodySmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color ?? colors.textSecondary,
        height: 1.4,
      );

  TextStyle metadata({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? colors.textSecondary,
        letterSpacing: 0,
      );

  TextStyle caption({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color ?? colors.textMuted,
        letterSpacing: 0.1,
      );

  TextStyle button({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white,
        letterSpacing: 0.1,
      );

  TextStyle badge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color ?? colors.textPrimary,
        letterSpacing: 0.2,
      );

  TextStyle codeOrId({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color ?? colors.primaryNavy,
        letterSpacing: 0.5,
      );
}

// Temporary class to avoid unresolved symbols if any files still use AppTextStyles statically
class AppTextStyles {
  static TextStyle pageTitle({Color? color}) =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5, height: 1.25);
  static TextStyle pageSubtitle({Color? color}) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color, letterSpacing: -0.1, height: 1.4);
  static TextStyle sectionHeading({Color? color}) =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.3, height: 1.3);
  static TextStyle sectionSubheading({Color? color}) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: color, letterSpacing: -0.1, height: 1.3);
  static TextStyle cardTitle({Color? color}) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.2, height: 1.35);
  static TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: color, height: 1.5);
  static TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color, height: 1.45);
  static TextStyle bodySmall({Color? color}) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: color, height: 1.4);
  static TextStyle metadata({Color? color}) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color, letterSpacing: 0);
  static TextStyle caption({Color? color}) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: color, letterSpacing: 0.1);
  static TextStyle button({Color? color}) =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.1);
  static TextStyle badge({Color? color}) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.2);
  static TextStyle codeOrId({Color? color}) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5);
}
