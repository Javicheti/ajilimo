import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/connectivity/presentation/connectivity_page.dart';

import 'support/fake_api.dart';

void main() {
  testWidgets('Muestra conectividad y acciones masivas', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: ConnectivityPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conectividad'), findsWidgets);
    expect(find.text('Abrir tiendas'), findsOneWidget);
    expect(find.text('Alenka´s Bakery - Callao'), findsOneWidget);
  });

  testWidgets('Abre el detalle por día y hora', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(2400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: ConnectivityPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver por día y hora').first);
    await tester.pumpAndSettle();

    expect(find.text('Conectividad por día y hora'), findsOneWidget);
    expect(find.text('Abrir tienda'), findsOneWidget);
  });
}
