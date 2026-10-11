import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/app/app.dart';
import 'package:backoffice/core/api/api_client.dart';

import 'support/fake_api.dart';

void main() {
  Widget build() => ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: const AjilimoApp(),
      );

  testWidgets('La app monta el shell con sidebar', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    expect(find.text('AJÍ LIMO'), findsOneWidget);
    expect(find.text('Torre de control'), findsWidgets);
    expect(find.text('Reportes'), findsOneWidget);
  });

  testWidgets('Navega entre páginas desde el sidebar', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Exportar CSV'), findsOneWidget);
  });
}
