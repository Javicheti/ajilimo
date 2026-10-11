import 'package:flutter/material.dart';

import 'tokens.dart';

/// Paleta de marca (white-label). Permite que cada tenant/marca tenga su color
/// sobre los tokens base. Se puede construir desde Firestore con [fromJson].
@immutable
class BrandPalette {
  const BrandPalette({
    required this.primary,
    required this.primaryHover,
    required this.soft,
  });

  final Color primary;
  final Color primaryHover;
  final Color soft;

  static const BrandPalette ajiLimo = BrandPalette(
    primary: Palette.orange,
    primaryHover: Palette.orangeHover,
    soft: Palette.peach,
  );

  factory BrandPalette.fromJson(Map<String, dynamic> json) {
    Color parse(Object? value, Color fallback) {
      if (value is! String) return fallback;
      final hex = value.replaceFirst('#', '').trim();
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed == null) return fallback;
      return Color(hex.length == 6 ? (0xFF000000 | parsed) : parsed);
    }

    return BrandPalette(
      primary: parse(json['primary'], ajiLimo.primary),
      primaryHover: parse(json['primaryHover'], ajiLimo.primaryHover),
      soft: parse(json['soft'], ajiLimo.soft),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'primary': hex(primary),
        'primaryHover': hex(primaryHover),
        'soft': hex(soft),
      };

  static String hex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  BrandPalette copyWith({
    Color? primary,
    Color? primaryHover,
    Color? soft,
  }) {
    return BrandPalette(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      soft: soft ?? this.soft,
    );
  }
}
