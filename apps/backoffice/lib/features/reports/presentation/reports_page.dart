import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sales.dart';
import 'reports_providers.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportDimension _dimension = ReportDimension.brand;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<SalesOrder> orders = ref.read(reportsRepositoryProvider).seed();
    final List<SalesRow> rows = aggregateSales(orders, _dimension);

    final int completed = rows.fold(0, (sum, r) => sum + r.completedOrders);
    final int cancelledPaid = rows.fold(0, (sum, r) => sum + r.cancelledPaidOrders);
    final int cancelledUnpaid = rows.fold(0, (sum, r) => sum + r.cancelledUnpaidOrders);
    final double paid = rows.fold(0.0, (sum, r) => sum + r.paidAmount);
    final int wings = rows.fold(0, (sum, r) => sum + r.wingUnits);
    final int sodas = rows.fold(0, (sum, r) => sum + r.sodaUnits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de ventas'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _export(context, rows),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Exportar CSV'),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: <Widget>[
                  _kpi(context, 'Culminados', '$completed', c.success, Icons.check_circle_outline),
                  _kpi(context, 'Canc. pagados', '$cancelledPaid', c.warning, Icons.receipt_outlined),
                  _kpi(context, 'Canc. no pagados', '$cancelledUnpaid', c.danger, Icons.cancel_outlined),
                  _kpi(context, 'Monto pagado', 'S/ ${paid.toStringAsFixed(2)}', c.brandPrimary, Icons.payments_outlined),
                  _kpi(context, 'Alas (u)', '$wings', c.info, Icons.set_meal_outlined),
                  _kpi(context, 'Gaseosas (u)', '$sodas', c.info, Icons.local_drink_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              SectionHeader(
                title: 'Detalle',
                action: SegmentedButton<ReportDimension>(
                  segments: ReportDimension.values
                      .map(
                        (d) => ButtonSegment<ReportDimension>(value: d, label: Text(d.label)),
                      )
                      .toList(),
                  selected: <ReportDimension>{_dimension},
                  onSelectionChanged: (selection) => setState(() => _dimension = selection.first),
                ),
              ),
              AppCard(
                padding: const EdgeInsets.all(Spacing.xs),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Clave')),
                      DataColumn(label: Text('Culminados'), numeric: true),
                      DataColumn(label: Text('Canc. pagados'), numeric: true),
                      DataColumn(label: Text('Canc. no pag.'), numeric: true),
                      DataColumn(label: Text('Monto'), numeric: true),
                      DataColumn(label: Text('Alas'), numeric: true),
                      DataColumn(label: Text('Gaseosas'), numeric: true),
                    ],
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(row.key)),
                              DataCell(Text('${row.completedOrders}')),
                              DataCell(Text('${row.cancelledPaidOrders}')),
                              DataCell(Text('${row.cancelledUnpaidOrders}')),
                              DataCell(Text(row.paidAmount.toStringAsFixed(2))),
                              DataCell(Text('${row.wingUnits}')),
                              DataCell(Text('${row.sodaUnits}')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpi(BuildContext context, String label, String value, Color accent, IconData icon) {
    return SizedBox(
      width: 200,
      child: KpiCard(label: label, value: value, icon: icon, accent: accent),
    );
  }

  void _export(BuildContext context, List<SalesRow> rows) {
    final String csv = salesToCsv(rows);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar CSV'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(csv, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
