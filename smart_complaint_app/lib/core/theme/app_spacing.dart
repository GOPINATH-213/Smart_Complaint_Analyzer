import 'package:flutter/material.dart';

/// Centralized Enterprise Spacing & Inset Scale
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double hero = 48.0;

  // Reusable EdgeInsets
  static const EdgeInsets p4 = EdgeInsets.all(xxs);
  static const EdgeInsets p8 = EdgeInsets.all(xs);
  static const EdgeInsets p12 = EdgeInsets.all(sm);
  static const EdgeInsets p16 = EdgeInsets.all(md);
  static const EdgeInsets p20 = EdgeInsets.all(lg);
  static const EdgeInsets p24 = EdgeInsets.all(xl);
  static const EdgeInsets p32 = EdgeInsets.all(xxl);

  // Horizontal Edge Insets
  static const EdgeInsets px16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets px20 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets px24 = EdgeInsets.symmetric(horizontal: xl);

  // Vertical Edge Insets
  static const EdgeInsets py8 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets py12 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets py16 = EdgeInsets.symmetric(vertical: md);

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: md);

  // SizedBox Spacers
  static const SizedBox h4 = SizedBox(height: xxs);
  static const SizedBox h8 = SizedBox(height: xs);
  static const SizedBox h12 = SizedBox(height: sm);
  static const SizedBox h16 = SizedBox(height: md);
  static const SizedBox h20 = SizedBox(height: lg);
  static const SizedBox h24 = SizedBox(height: xl);
  static const SizedBox h32 = SizedBox(height: xxl);

  static const SizedBox w4 = SizedBox(width: xxs);
  static const SizedBox w8 = SizedBox(width: xs);
  static const SizedBox w12 = SizedBox(width: sm);
  static const SizedBox w16 = SizedBox(width: md);
  static const SizedBox w20 = SizedBox(width: lg);
  static const SizedBox w24 = SizedBox(width: xl);
}
