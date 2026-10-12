import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/core/api/api_client.dart';
import 'package:backoffice/features/menu/presentation/menu_page.dart';

import 'support/fake_api.dart';

void main() {
  testWidgets('Muestra Tu Menú con categorías y productos', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApi())],
        child: MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: MenuPage())),
      ),
    );

    expect(find.text('Tu Menú'), findsOneWidget);
    expect(find.text('Maestro'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Postres'), findsOneWidget);
    expect(find.text('Cheesecake Nutella'), findsOneWidget);
  });
}
