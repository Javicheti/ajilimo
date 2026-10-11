import 'package:flutter/material.dart';

/// Marca de AjíLimo usando el logo oficial (`assets/brand/logo.png`).
///
/// - Modo por defecto: logo completo (emblema + wordmark).
/// - [emblemOnly]: recorta el emblema circular (izquierda) y lo muestra en un círculo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36, this.emblemOnly = false});

  /// Alto del logo en pantalla (para el emblema, es el diámetro).
  final double size;
  final bool emblemOnly;

  static const String asset = 'packages/ajilimo_shared/assets/brand/logo.png';

  @override
  Widget build(BuildContext context) {
    if (emblemOnly) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              asset,
              height: size,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }
    return Image.asset(
      asset,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
