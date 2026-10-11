import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/app/app.dart';

void main() {
  testWidgets('La app arranca en la Home de AjíLimo', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AjilimoApp()));
    await tester.pumpAndSettle();

    expect(find.text('AjíLimo'), findsOneWidget);
    expect(find.text('Ver design system'), findsOneWidget);
  });

  testWidgets('Navega a la galería de diseño', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AjilimoApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver design system'));
    await tester.pumpAndSettle();

    expect(find.text('Design System — AjíLimo'), findsOneWidget);
  });
}
