import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:korn_tablet/app/app.dart';

const List<String> items = <String>[
  'Makis / alas según pedido',
  'Gaseosa (si aplica)',
  'Extras y salsas',
  'Ticket en el encuadre',
];

Future<void> completeChecklist(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'R-4821');
  for (final String item in items) {
    await tester.tap(find.text(item));
    await tester.pump();
  }
}

void main() {
  testWidgets('Muestra el Paso 1 del flujo KORN', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KornApp()));
    await tester.pumpAndSettle();

    expect(find.text('KORN · Evidencia del pedido'), findsOneWidget);
    expect(find.text('Paso 1 · Checklist'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('Requiere checklist y número de pedido para continuar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KornApp()));
    await tester.pumpAndSettle();

    FilledButton continuar() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar'));

    expect(continuar().onPressed, isNull);

    for (final String item in items) {
      await tester.tap(find.text(item));
      await tester.pump();
    }
    // Sin número de pedido sigue bloqueado.
    expect(continuar().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'R-4821');
    await tester.pump();
    expect(continuar().onPressed, isNotNull);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Paso 2 · Foto'), findsOneWidget);
  });

  testWidgets('Flujo completo exige foto y permite entregar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KornApp()));
    await tester.pumpAndSettle();

    await completeChecklist(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Sin foto, no se puede continuar.
    final FilledButton pasoFoto =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continuar'));
    expect(pasoFoto.onPressed, isNull);

    await tester.tap(find.text('Capturar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Paso 3 · Validación (10 s)'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Paso 4 · Entregar'), findsOneWidget);
    await tester.tap(find.text('Entregar al rider'));
    await tester.pump();

    expect(find.text('Evidencia registrada y pedido entregado'), findsOneWidget);
  });
}
