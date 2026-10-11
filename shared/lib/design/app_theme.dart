import 'package:flutter/material.dart';

import 'brand.dart';
import 'elevations.dart';
import 'semantic_colors.dart';
import 'tokens.dart';
import 'typography.dart';
/// Construye el [ThemeData] de AjíLimo a partir de los tokens y una [BrandPalette].
class AppTheme {
  const AppTheme._();

  static ThemeData light({BrandPalette brand = BrandPalette.ajiLimo}) =>
      _build(Brightness.light, brand);

  static ThemeData dark({BrandPalette brand = BrandPalette.ajiLimo}) =>
      _build(Brightness.dark, brand);

  static ThemeData _build(Brightness brightness, BrandPalette brand) {
    final bool isDark = brightness == Brightness.dark;
    final AppColors colors = isDark ? AppColors.dark(brand) : AppColors.light(brand);

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brand.primary,
      brightness: brightness,
    ).copyWith(
      primary: brand.primary,
      surface: colors.surface,
      error: colors.danger,
      outline: colors.border,
    );

    final TextTheme text = AppTypography.textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.bodyFamily,
      scaffoldBackgroundColor: colors.background,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[colors],
      dividerColor: colors.border,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textStrong,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: brand.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: text.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textStrong,
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceAlt,
        side: BorderSide(color: colors.border),
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.textStrong,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: colors.surface),
      ),
    );
  }

  static List<BoxShadow> get cardShadow => AppShadows.sm;
}
