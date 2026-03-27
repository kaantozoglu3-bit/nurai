import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;

  // Border Radius — legacy
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusFull = 100.0;

  // Border Radius — Stitch Design System
  static const double radiusCard = 24.0;   // ana kartlar (rounded-[2rem])
  static const double radiusItem = 16.0;   // liste item'ları
  static const double radiusChip = 100.0;  // chip'ler ve pill'ler
  static const double radiusIcon = 12.0;   // ikon container'ları

  // Button
  static const double buttonHeight = 52.0;
  static const double buttonHeightS = 40.0;

  // Input
  static const double inputHeight = 52.0;

  // Icon
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // Card elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Bottom nav height
  static const double bottomNavHeight = 64.0;

  // Stitch shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F2F3332),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow navShadow = BoxShadow(
    color: Color(0x0F2F3332),
    blurRadius: 24,
    offset: Offset(0, -8),
  );
}
