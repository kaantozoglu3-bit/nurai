import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Stitch Design System ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF006D4E);
  static const Color primaryContainer = Color(0xFF86F8C9);
  static const Color secondary = Color(0xFF3F6751);
  static const Color secondaryContainer = Color(0xFFC0EDD0);
  static const Color background = Color(0xFFF9F9F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFECEEEC);
  static const Color surfaceContainerLow = Color(0xFFF3F4F2);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E6);
  static const Color onSurface = Color(0xFF2F3332);
  static const Color onSurfaceVariant = Color(0xFF5C605E);
  static const Color outline = Color(0xFF777C79);
  static const Color outlineVariant = Color(0xFFAFB3B0);
  static const Color error = Color(0xFFA83836);
  static const Color errorContainer = Color(0xFFFA746F);
  static const Color tertiary = Color(0xFF6A5E46);
  static const Color tertiaryContainer = Color(0xFFFEECCE);
  static const Color onTertiaryContainer = Color(0xFF635740);

  // ── Backward-compatible aliases ─────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF86F8C9);
  static const Color primaryDark = Color(0xFF004D37);
  static const Color secondaryLight = Color(0xFFC0EDD0);
  static const Color surfaceVariant = surfaceContainerLow;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint = outline;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color border = outlineVariant;
  static const Color divider = surfaceContainerLow;
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color chatUserBubble = primary;
  static const Color chatAIBubble = surfaceContainerLow;

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF006D4E), Color(0xFF3F6751)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF9F9F7), Color(0xFFECEEEC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadow ──────────────────────────────────────────────────────────────────
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F2F3332),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // ── Dark mode ────────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1512);
  static const Color surfaceDark = Color(0xFF1A2420);
  static const Color surfaceVariantDark = Color(0xFF2A3530);
  static const Color textPrimaryDark = Color(0xFFE8F5EF);
  static const Color textSecondaryDark = Color(0xFF8EA89D);
  static const Color borderDark = Color(0xFF3A4540);
}
