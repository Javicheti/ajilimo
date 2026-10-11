import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/settings/presentation/integrations_page.dart';

import 'support/fake_api.dart';

void main() {
  Widget build() => ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const IntegrationsPage(),
        ),
      );

  testWidgets('Lista los canales configurados', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(build());

    expect(find.text('Rappi'), findsWidgets);
    expect(find.text('DiDi'), findsWidgets);
    expect(find.text('PedidosYa'), findsWidgets);
    expect(find.text('Falta configurar'), findsNWidgets(3));
  });

  testWidgets('Probar conexión en mock responde OK', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(build());

    await tester.tap(find.text('Probar conexión').first);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Conexión OK'), findsOneWidget);
  });
}
