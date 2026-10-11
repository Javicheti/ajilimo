import 'package:flutter/widgets.dart';

/// Entrada de navegación del shell.
class NavEntry {
  const NavEntry({
    required this.route,
    required this.label,
    required this.icon,
    this.badge,
    this.enabled = true,
  });

  final String route;
  final String label;
  final IconData icon;
  final int? badge;
  final bool enabled;
}

/// Grupo de navegación del sidebar.
class NavGroup {
  const NavGroup({required this.label, required this.entries});

  final String label;
  final List<NavEntry> entries;
}
