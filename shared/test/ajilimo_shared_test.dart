import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BrandPalette hace round-trip a JSON', () {
    const BrandPalette original = BrandPalette.ajiLimo;
    final BrandPalette restored = BrandPalette.fromJson(original.toJson());
    expect(restored.primary, original.primary);
    expect(restored.primaryHover, original.primaryHover);
    expect(restored.soft, original.soft);
  });

  test('AppTheme construye claro y oscuro con extensión AppColors', () {
    final ThemeData light = AppTheme.light();
    final ThemeData dark = AppTheme.dark();
    expect(light.extension<AppColors>(), isNotNull);
    expect(dark.extension<AppColors>(), isNotNull);
    expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
  });

  testWidgets('StatusChip muestra la etiqueta de estado', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: StatusChip(status: StoreStatus.suspended)),
      ),
    );
    expect(find.text('Suspendido'), findsOneWidget);
  });

  testWidgets('ChannelBadge muestra el canal', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: ChannelBadge(channel: DeliveryChannel.rappi)),
      ),
    );
    expect(find.text('Rappi'), findsOneWidget);
  });

  testWidgets('DesignGalleryPage renderiza', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: DesignGalleryPage()),
      ),
    );
    await tester.pump();
    expect(find.text('Design System — AjíLimo'), findsOneWidget);
  });
}
