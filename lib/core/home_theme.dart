import 'package:flutter/material.dart';

/// Цвета и размеры из Figma/CSS Home page.
abstract final class HomeTheme {
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFF8F7FF);
  static const Color primary = Color(0xFF1E1B4B);
  static const Color accent = Color(0xFF462370);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentSurface = Color(0xFFEDE9FE);
  static const Color chipInactive = Color(0xFFF1F0F9);
  /// Чипы фильтра Home (Figma: active #432C7A, inactive #F2F0F9).
  static const Color filterChipActive = Color(0xFF462370);
  static const Color filterChipInactive = Color(0xFFF2F0F9);
  static const Color inputBackground = chipInactive;
  static const Color placeholder = Color(0xFFA09DC5);
  static const Color companyTint = Color(0xFFC4B5FD);
  static const Color tagMuted = Color(0xFF6B7280);
  static const Color infoBox = Color(0xFF27236B);
  static const Color profileTitle = Color(0xFF27236B);
  static const Color clearAction = Color(0xFF4C1D95);
  static const Color badgeLight = Color(0xFFF8F7FF);
  static const Color bodyText = Color(0xFF0F0E2A);
  static const Color error = Color(0xFFEF4444);

  static const double horizontalPadding = 16;
  static const double contentWidth = 358;
  static const double sectionGap = 16;
  static const double sectionInnerGap = 8;
  static const double cardRadius = 25;
  static const double chipRadius = 40;
  static const double tagRadius = 16;
}
