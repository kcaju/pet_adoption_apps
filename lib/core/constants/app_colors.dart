import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFFFF6F43); // Warm Terracotta / Coral
  static const Color primaryLight = Color(0xFFFFE8E0);
  static const Color primaryDark = Color(0xFFD64D24);

  // Secondary & Accents
  static const Color secondary = Color(0xFF2EC4B6); // Mint / Teal
  static const Color secondaryLight = Color(0xFFE0F7F5);
  static const Color accent = Color(0xFFFFBF00); // Warm Gold

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF3F4F6);
  static const Color cardBorder = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
