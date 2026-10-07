import 'package:flutter/material.dart';

/// Centralized Enterprise Subtle Shadow Tokens
class AppShadows {
  // Ultra subtle card elevation
  static List<BoxShadow> get cardSubtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // Elevated modal/sheet elevation
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // AI Glow Accent subtle shadow
  static List<BoxShadow> get aiSubtle => [
        BoxShadow(
          color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  // Navbar bottom shadow
  static List<BoxShadow> get navbar => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  // Bottom navigation top shadow
  static List<BoxShadow> get bottomBar => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ];
}
