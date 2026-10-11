import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/auth/presentation/login_page.dart';

void main() {
  Widget build() => ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const LoginPage()),
      );

  testWidgets('Muestra el formulario de ingreso', (WidgetTester tester) async {
    await tester.pumpWidget(build());
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Ingresar'), findsOneWidget);
  });

  testWidgets('Alterna al modo registro', (WidgetTester tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pump();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Crear cuenta'), findsOneWidget);
  });
}
