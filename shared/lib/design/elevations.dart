import 'package:flutter/material.dart';

/// Sombras del sistema.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
