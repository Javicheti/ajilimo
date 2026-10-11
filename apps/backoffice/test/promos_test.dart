import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/promos/presentation/promos_page.dart';

void main() {
  testWidgets('Muestra estados de promos y sabores', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const PromosPage()),
      ),
    );

    expect(find.text('Promociones y sabores'), findsOneWidget);
    expect(find.text('Activo'), findsWidgets);
    expect(find.text('Apagado'), findsWidgets);
    expect(find.text('Suspendido'), findsWidgets);
    expect(find.text('A precio full'), findsWidgets);
    expect(find.text('Promo Makis + Alas'), findsOneWidget);
  });
}
