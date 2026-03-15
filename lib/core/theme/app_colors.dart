import 'package:flutter/material.dart';

/// Color constants for Fidyah-AI design system
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0D7C5F);
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primaryLight = Color(0xFF34D399);

  // Accent
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentLight = Color(0xFFF5E6A3);

  // Surface
  static const Color surface = Color(0xFFF0FDF4);
  static const Color surfaceDark = Color(0xFF0F1A14);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1A1A);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  // Chat specific
  static const Color userBubble = primary;
  static const Color aiBubble = Color(0xFFE8F5E9);
  static const Color inputBarBg = Color(0xFFF9FAFB);
  static const Color divider = Color(0xFFE5E7EB);

  // Overlay
  static const Color overlayDark = Color(0x99000000);
}
