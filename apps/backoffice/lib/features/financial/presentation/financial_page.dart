import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/financial_repository.dart';

class FinancialPage extends ConsumerWidget {
  const FinancialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final List<PaymentRow> rows = ref.read(financialRepositoryProvider).seed();
    final double paid = rows.where((r) => r.status == PaymentStatus.paid).fold(0, (s, r) => s + (r.amount ?? 0));
    final int pending = rows.where((r) => r.status == PaymentStatus.zeroBalance).length;

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        const PageHeader(
          icon: Icons.account_balance_wallet_outlined,
          eyebrow: 'Financiero',
          title: 'Financiero',
          subtitle: 'Pagos, transferencias y conciliación por tienda',
        ),
        FilterBar(
          items: const <FilterItem>[
            FilterItem(label: 'Periodo', value: 'Últimos 7 días', icon: Icons.calendar_today_outlined),
            FilterItem(label: 'Estado', value: 'Todos'),
          ],
          actions: <Widget>[
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Generar reporte'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          children: <Widget>[
            SizedBox(width: 220, child: KpiCard(label: 'Pagado (periodo)', value: 'S/ ${paid.toStringAsFixed(2)}', icon: Icons.check_circle_outline, accent: c.success)),
            SizedBox(width: 220, child: KpiCard(label: 'Pagos pendientes', value: '$pending', icon: Icons.pending_outlined, accent: c.warning)),
            SizedBox(width: 220, child: KpiCard(label: 'Total pagos', value: '${rows.length}', icon: Icons.receipt_long_outlined, accent: c.brandPrimary)),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        DataTableCard(
          title: 'Pagos en el periodo',
          columns: const <TableColumn>[
            TableColumn('ID pago'),
            TableColumn('Tienda / Marca'),
            TableColumn('Fecha de pago'),
            TableColumn('Periodo de venta'),
            TableColumn('Valor a transferir', numeric: true),
            TableColumn('Estado'),
          ],
          rows: <List<Widget>>[
            for (final PaymentRow row in rows)
              <Widget>[
                Text(row.paymentId),
                Text(row.storeOrBrand),
                Text(row.paymentDate),
                Text(row.salePeriod),
                Text(row.amount == null ? '—' : 'S/ ${row.amount!.toStringAsFixed(2)}'),
                _statusChip(context, row.status),
              ],
          ],
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, PaymentStatus status) {
    final AppColors c = context.colors;
    final bool paid = status == PaymentStatus.paid;
    final Color color = paid ? c.success : c.textMid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        paid ? 'Pagado' : 'Balance 0 o negativo',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
