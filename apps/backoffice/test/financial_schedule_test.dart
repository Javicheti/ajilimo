import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/financial/presentation/financial_page.dart';
import 'package:backoffice/features/schedule/presentation/schedule_page.dart';

void main() {
  testWidgets('Financiero: KPIs y tabla de pagos', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: FinancialPage())),
      ),
    );

    expect(find.text('Financiero'), findsWidgets);
    expect(find.text('Pagos en el periodo'), findsOneWidget);
    expect(find.text('Pagado'), findsWidgets);
  });

  testWidgets('Horarios: horas registradas y días', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: SchedulePage())),
      ),
    );

    expect(find.text('Horarios'), findsWidgets);
    expect(find.text('Horas registradas'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });
}
