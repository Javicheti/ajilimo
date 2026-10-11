enum OrderOutcome { completed, cancelledPaid, cancelledUnpaid }

enum ProductCategory { makis, alas, gaseosa, otro }

extension ProductCategoryX on ProductCategory {
  String get label => switch (this) {
        ProductCategory.makis => 'Makis',
        ProductCategory.alas => 'Alas',
        ProductCategory.gaseosa => 'Gaseosa',
        ProductCategory.otro => 'Otro',
      };
}

class SalesLine {
  const SalesLine({required this.category, required this.quantity});
  final ProductCategory category;
  final int quantity;
}

class SalesOrder {
  const SalesOrder({
    required this.orderId,
    required this.brand,
    required this.channel,
    required this.storeId,
    required this.outcome,
    required this.paidAmount,
    required this.date,
    required this.lines,
  });

  final String orderId;
  final String brand;
  final String channel;
  final String storeId;
  final OrderOutcome outcome;
  final double paidAmount;
  final DateTime date;
  final List<SalesLine> lines;
}

class SalesRow {
  SalesRow(this.key);
  final String key;
  int completedOrders = 0;
  int cancelledPaidOrders = 0;
  int cancelledUnpaidOrders = 0;
  double paidAmount = 0;
  int wingUnits = 0;
  int sodaUnits = 0;

  int get totalOrders => completedOrders + cancelledPaidOrders + cancelledUnpaidOrders;
}

enum ReportDimension { brand, channel, store, day, month, product }

extension ReportDimensionX on ReportDimension {
  String get label => switch (this) {
        ReportDimension.brand => 'Marca',
        ReportDimension.channel => 'App',
        ReportDimension.store => 'Tienda',
        ReportDimension.day => 'Día',
        ReportDimension.month => 'Mes',
        ReportDimension.product => 'Producto',
      };

  String keyOf(SalesOrder order) => switch (this) {
        ReportDimension.brand => order.brand,
        ReportDimension.channel => order.channel,
        ReportDimension.store => order.storeId,
        ReportDimension.day => _day(order.date),
        ReportDimension.month => _month(order.date),
        ReportDimension.product =>
          (order.lines.map((line) => line.category.label).toSet().toList()..sort()).join('+'),
      };
}

String _two(int value) => value.toString().padLeft(2, '0');
String _day(DateTime date) => '${date.year}-${_two(date.month)}-${_two(date.day)}';
String _month(DateTime date) => '${date.year}-${_two(date.month)}';

List<SalesRow> aggregateSales(List<SalesOrder> orders, ReportDimension dimension) {
  final Map<String, SalesRow> rows = <String, SalesRow>{};
  for (final SalesOrder order in orders) {
    final SalesRow row = rows.putIfAbsent(dimension.keyOf(order), () => SalesRow(dimension.keyOf(order)));
    switch (order.outcome) {
      case OrderOutcome.completed:
        row.completedOrders += 1;
      case OrderOutcome.cancelledPaid:
        row.cancelledPaidOrders += 1;
      case OrderOutcome.cancelledUnpaid:
        row.cancelledUnpaidOrders += 1;
    }
    row.paidAmount += order.paidAmount;
    for (final SalesLine line in order.lines) {
      if (line.category == ProductCategory.alas) row.wingUnits += line.quantity;
      if (line.category == ProductCategory.gaseosa) row.sodaUnits += line.quantity;
    }
  }
  return rows.values.toList()..sort((a, b) => a.key.compareTo(b.key));
}

String salesToCsv(List<SalesRow> rows) {
  final StringBuffer buffer = StringBuffer()
    ..writeln('clave,culminados,cancelados_pagados,cancelados_no_pagados,monto_pagado,alas,gaseosas');
  for (final SalesRow row in rows) {
    buffer.writeln(
      '${row.key},${row.completedOrders},${row.cancelledPaidOrders},'
      '${row.cancelledUnpaidOrders},${row.paidAmount.toStringAsFixed(2)},'
      '${row.wingUnits},${row.sodaUnits}',
    );
  }
  return buffer.toString();
}
