import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/orders/presentation/orders_page.dart';

import 'support/fake_api.dart';

void main() {
  Widget build() => ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const OrdersPage(),
        ),
      );

  testWidgets('Muestra órdenes, objetivo y estado excedido', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pump();

    expect(find.text('Órdenes · Cooking time'), findsOneWidget);
    expect(find.text('Objetivo 22 min'), findsOneWidget);
    expect(find.text('Excedido'), findsOneWidget);
    expect(find.text('Tomar (22 min)'), findsOneWidget);
  });

  testWidgets('Tomar orden inicia el cooking time', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(build());
    await tester.pump();

    expect(find.text('Tomar (22 min)'), findsOneWidget);
    await tester.tap(find.text('Tomar (22 min)'));
    await tester.pump();

    expect(find.text('Tomar (22 min)'), findsNothing);
    expect(find.text('En tiempo'), findsWidgets);
  });
}
