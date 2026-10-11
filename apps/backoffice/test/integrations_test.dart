import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/settings/presentation/integrations_page.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Lista los canales configurados', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const IntegrationsPage(),
        ),
      ),
    );

    expect(find.text('Configuración · Integraciones'), findsOneWidget);
    expect(find.text('Rappi'), findsWidgets);
    expect(find.text('DiDi'), findsWidgets);
    expect(find.text('PedidosYa'), findsWidgets);
    expect(find.text('Falta configurar'), findsNWidgets(3));
  });

  testWidgets('Probar conexión en mock responde OK', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const IntegrationsPage(),
        ),
      ),
    );

    await tester.tap(find.text('Probar conexión').first);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Conexión OK'), findsOneWidget);
  });
}
