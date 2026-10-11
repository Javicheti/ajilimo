import 'package:flutter/material.dart';

import 'semantic_colors.dart';

/// Tipografía del sistema: Sora (títulos) + Inter (datos) con cifras tabulares.
/// Las fuentes están empaquetadas en `assets/fonts/` (sin fetch en runtime).
class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'Sora';
  static const String bodyFamily = 'Inter';

  static TextTheme textTheme(AppColors colors) {
    TextStyle display(double size, FontWeight weight) => TextStyle(
          fontFamily: displayFamily,
          fontSize: size,
          fontWeight: weight,
          color: colors.textStrong,
          letterSpacing: -0.3,
          height: 1.15,
        );

    TextStyle body(double size, FontWeight weight, Color color) => TextStyle(
          fontFamily: bodyFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: 1.4,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        );

    return TextTheme(
      displayLarge: display(40, FontWeight.w700),
      displayMedium: display(32, FontWeight.w700),
      headlineLarge: display(28, FontWeight.w700),
      headlineMedium: display(24, FontWeight.w600),
      headlineSmall: display(20, FontWeight.w600),
      titleLarge: display(18, FontWeight.w600),
      titleMedium: body(16, FontWeight.w600, colors.textStrong),
      titleSmall: body(14, FontWeight.w600, colors.textStrong),
      bodyLarge: body(16, FontWeight.w400, colors.textStrong),
      bodyMedium: body(14, FontWeight.w400, colors.textStrong),
      bodySmall: body(12, FontWeight.w400, colors.textMid),
      labelLarge: body(14, FontWeight.w600, colors.textStrong),
      labelMedium: body(12, FontWeight.w500, colors.textMid),
      labelSmall: body(11, FontWeight.w500, colors.textFaint),
    );
  }
}
