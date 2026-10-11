import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/reports/domain/sales.dart';

SalesOrder order({
  required String brand,
  required String channel,
  required OrderOutcome outcome,
  required double paid,
  required DateTime date,
  required List<SalesLine> lines,
}) =>
    SalesOrder(
      orderId: 'x',
      brand: brand,
      channel: channel,
      storeId: 'S',
      outcome: outcome,
      paidAmount: paid,
      date: date,
      lines: lines,
    );

void main() {
  final orders = <SalesOrder>[
    order(
      brand: 'PINWINGS',
      channel: 'Rappi',
      outcome: OrderOutcome.completed,
      paid: 84.70,
      date: DateTime(2026, 1, 5),
      lines: const <SalesLine>[
        SalesLine(category: ProductCategory.alas, quantity: 8),
        SalesLine(category: ProductCategory.gaseosa, quantity: 2),
      ],
    ),
    order(
      brand: 'PINWINGS',
      channel: 'Rappi',
      outcome: OrderOutcome.cancelledPaid,
      paid: 30,
      date: DateTime(2026, 1, 5),
      lines: const <SalesLine>[SalesLine(category: ProductCategory.alas, quantity: 4)],
    ),
    order(
      brand: 'Makis',
      channel: 'DiDi',
      outcome: OrderOutcome.cancelledUnpaid,
      paid: 0,
      date: DateTime(2026, 1, 6),
      lines: const <SalesLine>[SalesLine(category: ProductCategory.makis, quantity: 10)],
    ),
  ];

  test('aggregateSales por marca agrega métricas y unidades', () {
    final rows = aggregateSales(orders, ReportDimension.brand);
    final pinwings = rows.firstWhere((r) => r.key == 'PINWINGS');
    expect(pinwings.completedOrders, 1);
    expect(pinwings.cancelledPaidOrders, 1);
    expect(pinwings.paidAmount, 114.70);
    expect(pinwings.wingUnits, 12);
    expect(pinwings.sodaUnits, 2);

    final makis = rows.firstWhere((r) => r.key == 'Makis');
    expect(makis.cancelledUnpaidOrders, 1);
  });

  test('aggregateSales por día separa fechas', () {
    final rows = aggregateSales(orders, ReportDimension.day);
    expect(rows.length, 2);
    expect(rows.firstWhere((r) => r.key == '2026-01-05').completedOrders, 1);
  });

  test('salesToCsv incluye encabezado y filas', () {
    final csv = salesToCsv(aggregateSales(orders, ReportDimension.brand));
    expect(csv, contains('clave,culminados'));
    expect(csv, contains('PINWINGS'));
    expect(csv, contains('12'));
  });
}
