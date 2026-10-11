import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/claims/presentation/claims_page.dart';

void main() {
  Widget build() => ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const ClaimsPage()),
      );

  testWidgets('Muestra la bandeja de reclamos', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pump();

    expect(find.text('Reclamos · DiDi'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('D-3310'), findsOneWidget);
    expect(find.text('Calidad del producto'), findsOneWidget);
    expect(find.text('Aceptar'), findsWidgets);
  });

  testWidgets('Responder un reclamo lo retira de la bandeja', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pump();
    expect(find.text('D-3310'), findsOneWidget);

    await tester.tap(find.text('Aceptar').first);
    await tester.pump();

    expect(find.text('D-3310'), findsNothing);
    expect(find.text('Reclamo aceptado'), findsOneWidget);
  });
}
