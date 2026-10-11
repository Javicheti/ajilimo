import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de tema (claro/oscuro) conmutable desde el shell.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
