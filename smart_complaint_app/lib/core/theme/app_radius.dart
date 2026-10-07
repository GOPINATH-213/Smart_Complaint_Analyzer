import 'package:flutter/material.dart';

/// Centralized Enterprise Border Radius Tokens
class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double card = 14.0;
  static const double lg = 16.0;
  static const double sheet = 22.0;
  static const double full = 999.0;

  // BorderRadius objects
  static const BorderRadius r6 = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius r10 = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(md));
  static const BorderRadius r14 = BorderRadius.all(Radius.circular(card));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius r22 = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius rFull = BorderRadius.all(Radius.circular(full));

  // Top Rounded for Sheets & Modals
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(sheet));
}
