import 'package:flutter/material.dart';

/// Valores crudos del sistema de diseño (primitivos).
/// Ningún widget debe usar estos directamente: los roles semánticos viven en
/// `AppColors` (semantic_colors.dart).
class Palette {
  const Palette._();

  // Marca (tomada del logo AjíLimo)
  static const Color orange = Color(0xFFC6362A); // ají rojo
  static const Color orangeHover = Color(0xFFA82A20);
  static const Color peach = Color(0xFFFBE9E5); // crema rosado
  static const Color maroon = Color(0xFF7A1F1F); // tipografía del logo
  static const Color lime = Color(0xFF7FA82E); // lima/limón
  static const Color teal = Color(0xFF2E8B8B); // ola

  static const Color carbon = Color(0xFF16161A);
  static const Color ink = Color(0xFF1B1B1F);
  static const Color textMid = Color(0xFF6B6B70);
  static const Color textFaint = Color(0xFF9A9AA0);
  static const Color border = Color(0xFFE6E6EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F8);

  static const Color success = Color(0xFF7FA82E); // lima
  static const Color warning = Color(0xFFE8952A); // naranja del ají
  static const Color danger = Color(0xFFE5484D);
  static const Color suspended = Color(0xFF7C3AED);
  static const Color info = Color(0xFF2E8B8B); // teal

  static const Color channelRappi = Color(0xFFFF441F);
  static const Color channelDidi = Color(0xFFFF8A00);
  static const Color channelPedidosya = Color(0xFFE5004D);

  static const Color darkBackground = Color(0xFF0F0F12);
  static const Color darkSurface = Color(0xFF1B1B1F);
  static const Color darkSurfaceAlt = Color(0xFF232329);
  static const Color darkBorder = Color(0xFF2A2A31);
  static const Color darkTextStrong = Color(0xFFF5F5F7);
  static const Color darkTextMid = Color(0xFF9A9AA0);
  static const Color darkTextFaint = Color(0xFF6B6B70);
}

/// Escala de espaciado (base 4 px).
class Spacing {
  const Spacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Radios de borde.
class Radii {
  const Radii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Duraciones de animación.
class Durations {
  const Durations._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Puntos de quiebre responsivos.
class Breakpoints {
  const Breakpoints._();
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1600;
}
