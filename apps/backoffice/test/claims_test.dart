import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/claims/presentation/claims_page.dart';

import 'support/fake_api.dart';

void main() {
  Widget build({List<Map<String, dynamic>> claims = const <Map<String, dynamic>>[]}) => ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi(claims: claims))],
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

  testWidgets('Usa los reclamos del BFF cuando está disponible', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      build(
        claims: <Map<String, dynamic>>[
          <String, dynamic>{
            'claimId': 'C-9',
            'orderId': 'D-9000',
            'channel': 'didi',
            'reason': 'incomplete',
            'amount': 12.5,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('D-9000'), findsOneWidget);
    expect(find.text('Pedido incompleto'), findsOneWidget);
  });
}
