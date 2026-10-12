import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/reports/presentation/reports_page.dart';

import 'support/fake_api.dart';

void main() {
  testWidgets('Reporte muestra KPIs y exporta CSV', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(theme: AppTheme.light(), home: const ReportsPage()),
      ),
    );

    expect(find.text('Culminados'), findsWidgets);
    expect(find.text('Alas (u)'), findsOneWidget);
    expect(find.text('Monto pagado'), findsOneWidget);
    expect(find.text('PINWINGS'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Exportar CSV'));
    await tester.pumpAndSettle();

    expect(find.textContaining('clave,culminados'), findsOneWidget);
  });
}
