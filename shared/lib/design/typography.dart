import 'package:flutter/material.dart';

import 'semantic_colors.dart';

/// Tipografía basada en **Montserrat** + cifras tabulares.
/// Las fuentes están empaquetadas en `assets/fonts/` (sin fetch en runtime).
class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'Montserrat';
  static const String bodyFamily = 'Montserrat';

  static const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

  static TextTheme textTheme(AppColors colors) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.2,
      Color? color,
      double? letterSpacing,
    }) =>
        TextStyle(
          fontFamily: displayFamily,
          fontSize: size,
          height: height,
          fontWeight: weight,
          color: color ?? colors.textStrong,
          letterSpacing: letterSpacing,
        );

    return TextTheme(
      displayLarge: style(40, FontWeight.w700, height: 1.1),
      displayMedium: style(34, FontWeight.w700, height: 1.15),
      headlineLarge: style(32, FontWeight.w700),
      headlineMedium: style(28, FontWeight.w700),
      headlineSmall: style(24, FontWeight.w600, height: 1.25),
      titleLarge: style(20, FontWeight.w600),
      titleMedium: style(16, FontWeight.w600, height: 1.25),
      titleSmall: style(14, FontWeight.w600, height: 1.25),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.45, color: colors.textStrong),
      bodySmall: style(12, FontWeight.w400, height: 1.4, color: colors.textMid),
      labelLarge: style(14, FontWeight.w600, letterSpacing: 0.2),
      labelMedium: style(12, FontWeight.w600, letterSpacing: 0.2, color: colors.textMid),
      labelSmall: style(11, FontWeight.w500, letterSpacing: 0.2, color: colors.textFaint),
    );
  }

  /// Estilo para montos destacados (cifras tabulares).
  static TextStyle amount(Color color, {double size = 20, FontWeight weight = FontWeight.w600}) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        height: 1.2,
        fontWeight: weight,
        color: color,
        fontFeatures: _tabular,
      );

  static List<FontFeature> get tabularFigures => _tabular;
}
