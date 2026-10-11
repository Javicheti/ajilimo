import 'package:flutter/material.dart';

import 'brand.dart';
import 'tokens.dart';

/// Roles semánticos de color. Los widgets consumen estos (nunca `Palette`).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandPrimary,
    required this.brandPrimaryHover,
    required this.brandSoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textStrong,
    required this.textMid,
    required this.textFaint,
    required this.success,
    required this.warning,
    required this.danger,
    required this.suspended,
    required this.info,
    required this.channelRappi,
    required this.channelDidi,
    required this.channelPedidosya,
  });

  final Color brandPrimary;
  final Color brandPrimaryHover;
  final Color brandSoft;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textStrong;
  final Color textMid;
  final Color textFaint;
  final Color success;
  final Color warning;
  final Color danger;
  final Color suspended;
  final Color info;
  final Color channelRappi;
  final Color channelDidi;
  final Color channelPedidosya;

  static AppColors light(BrandPalette brand) => AppColors(
        brandPrimary: brand.primary,
        brandPrimaryHover: brand.primaryHover,
        brandSoft: brand.soft,
        background: Palette.background,
        surface: Palette.surface,
        surfaceAlt: Palette.background,
        border: Palette.border,
        textStrong: Palette.ink,
        textMid: Palette.textMid,
        textFaint: Palette.textFaint,
        success: Palette.success,
        warning: Palette.warning,
        danger: Palette.danger,
        suspended: Palette.suspended,
        info: Palette.info,
        channelRappi: Palette.channelRappi,
        channelDidi: Palette.channelDidi,
        channelPedidosya: Palette.channelPedidosya,
      );

  static AppColors dark(BrandPalette brand) => AppColors(
        brandPrimary: brand.primary,
        brandPrimaryHover: brand.primaryHover,
        brandSoft: brand.soft,
        background: Palette.darkBackground,
        surface: Palette.darkSurface,
        surfaceAlt: Palette.darkSurfaceAlt,
        border: Palette.darkBorder,
        textStrong: Palette.darkTextStrong,
        textMid: Palette.darkTextMid,
        textFaint: Palette.darkTextFaint,
        success: Palette.success,
        warning: Palette.warning,
        danger: Palette.danger,
        suspended: Palette.suspended,
        info: Palette.info,
        channelRappi: Palette.channelRappi,
        channelDidi: Palette.channelDidi,
        channelPedidosya: Palette.channelPedidosya,
      );

  @override
  AppColors copyWith({
    Color? brandPrimary,
    Color? brandPrimaryHover,
    Color? brandSoft,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textStrong,
    Color? textMid,
    Color? textFaint,
    Color? success,
    Color? warning,
    Color? danger,
    Color? suspended,
    Color? info,
    Color? channelRappi,
    Color? channelDidi,
    Color? channelPedidosya,
  }) {
    return AppColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryHover: brandPrimaryHover ?? this.brandPrimaryHover,
      brandSoft: brandSoft ?? this.brandSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textStrong: textStrong ?? this.textStrong,
      textMid: textMid ?? this.textMid,
      textFaint: textFaint ?? this.textFaint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      suspended: suspended ?? this.suspended,
      info: info ?? this.info,
      channelRappi: channelRappi ?? this.channelRappi,
      channelDidi: channelDidi ?? this.channelDidi,
      channelPedidosya: channelPedidosya ?? this.channelPedidosya,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryHover: Color.lerp(brandPrimaryHover, other.brandPrimaryHover, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      suspended: Color.lerp(suspended, other.suspended, t)!,
      info: Color.lerp(info, other.info, t)!,
      channelRappi: Color.lerp(channelRappi, other.channelRappi, t)!,
      channelDidi: Color.lerp(channelDidi, other.channelDidi, t)!,
      channelPedidosya: Color.lerp(channelPedidosya, other.channelPedidosya, t)!,
    );
  }
}

/// Acceso rápido a [AppColors] desde cualquier BuildContext.
extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light(BrandPalette.ajiLimo);
}
