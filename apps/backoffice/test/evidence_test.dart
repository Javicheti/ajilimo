import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/evidence/presentation/evidence_page.dart';

void main() {
  testWidgets('Muestra registros de evidencia', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const EvidencePage()),
      ),
    );

    expect(find.text('R-4821'), findsOneWidget);
    expect(find.text('Evidencia completa'), findsWidgets);
    expect(find.text('Evidencia incompleta'), findsOneWidget);
  });
}
