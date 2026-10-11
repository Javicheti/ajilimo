import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/control_tower/presentation/control_tower_page.dart';

import 'support/fake_api.dart';

Widget build(List<Map<String, dynamic>> rows) => ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(FakeApi(controlTower: rows))],
      child: MaterialApp(theme: AppTheme.light(), home: const ControlTowerPage()),
    );

void main() {
  testWidgets('Muestra KPIs y alertas (datos locales)', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build(<Map<String, dynamic>>[]));
    await tester.pumpAndSettle();

    expect(find.text('Torre de control'), findsOneWidget);
    expect(find.text('Abiertas'), findsOneWidget);
    expect(find.text('Suspendidas'), findsOneWidget);
    expect(find.text('Resumen por app'), findsOneWidget);
    expect(find.text('1 / 4 abiertas'), findsOneWidget);
    expect(find.text('4 tiendas requieren atención'), findsOneWidget);
  });

  testWidgets('Filtra por canal', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build(<Map<String, dynamic>>[]));
    await tester.pumpAndSettle();
    expect(find.text('6 tiendas'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'DiDi'));
    await tester.pumpAndSettle();

    expect(find.text('2 tiendas'), findsOneWidget);
  });

  testWidgets('Usa los datos del BFF cuando está disponible', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      build(<Map<String, dynamic>>[
        <String, dynamic>{
          'storeId': 'REM-1',
          'name': 'PINWINGS — Remota',
          'brand': 'PINWINGS',
          'channel': 'rappi',
          'status': 'paused',
        },
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('PINWINGS — Remota'), findsWidgets);
    expect(find.text('1 tiendas'), findsOneWidget);
  });
}
