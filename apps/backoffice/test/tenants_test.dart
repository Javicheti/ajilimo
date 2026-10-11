import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/tenants/presentation/tenants_page.dart';

void main() {
  Widget build() => ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const TenantsPage()),
      );

  testWidgets('Lista tenants existentes', (WidgetTester tester) async {
    await tester.pumpWidget(build());
    expect(find.text('AjíLimo (Operador)'), findsOneWidget);
    expect(find.text('slug: ajilimo'), findsOneWidget);
  });

  testWidgets('Crea un nuevo tenant con slug', (WidgetTester tester) async {
    await tester.pumpWidget(build());

    await tester.tap(find.widgetWithText(FilledButton, 'Nuevo tenant'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Pizzería Roma');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Pizzería Roma'), findsOneWidget);
    expect(find.text('slug: pizzeria-roma'), findsOneWidget);
  });
}
