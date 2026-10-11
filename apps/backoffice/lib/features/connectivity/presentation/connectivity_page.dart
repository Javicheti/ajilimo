import 'dart:math';

import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/connectivity_repository.dart';
import '../domain/connectivity.dart';

class ConnectivityPage extends ConsumerStatefulWidget {
  const ConnectivityPage({super.key});

  @override
  ConsumerState<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends ConsumerState<ConnectivityPage> {
  late List<ConnectivityRow> _rows;

  @override
  void initState() {
    super.initState();
    final ConnectivityRepository repository = ref.read(connectivityRepositoryProvider);
    _rows = repository.seed();
    _load(repository);
  }

  Future<void> _load(ConnectivityRepository repository) async {
    try {
      final List<ConnectivityRow> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _rows = remote);
    } catch (_) {
      // Sin BFF: se mantienen datos locales.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        const PageHeader(
          icon: Icons.wifi_tethering,
          eyebrow: 'Operación',
          title: 'Conectividad',
          subtitle: 'Estado en tiempo real de tus tiendas · abrir / cerrar de forma masiva',
        ),
        FilterBar(
          items: const <FilterItem>[
            FilterItem(label: 'Marca', value: 'Todas'),
            FilterItem(label: 'Sucursales', value: '14 tiendas'),
            FilterItem(label: 'País', value: 'Perú', icon: Icons.public),
          ],
          actions: <Widget>[
            OutlinedButton.icon(
              onPressed: () => _bulk(false),
              icon: const Icon(Icons.power_settings_new, size: 16),
              label: const Text('Cerrar tiendas'),
            ),
            FilledButton.icon(
              onPressed: () => _bulk(true),
              icon: const Icon(Icons.bolt_outlined, size: 16),
              label: const Text('Abrir tiendas'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        DataTableCard(
          title: 'Conectividad en tiempo real',
          subtitle: 'Promedio en 15 días',
          columns: const <TableColumn>[
            TableColumn('Tienda'),
            TableColumn('Canal'),
            TableColumn('Estado'),
            TableColumn('Más información'),
            TableColumn(''),
          ],
          rows: <List<Widget>>[
            for (final ConnectivityRow row in _rows)
              <Widget>[
                Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ChannelBadge(channel: row.channel),
                StatusChip(status: row.status, compact: true),
                Text(row.detail),
                DetailedButton(
                  icon: Icons.calendar_month_outlined,
                  label: 'Ver por día y hora',
                  onPressed: () => showConnectivityDetail(context, row),
                ),
              ],
          ],
        ),
      ],
    );
  }

  void _bulk(bool open) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(open ? 'Abriendo tiendas…' : 'Cerrando tiendas…')),
    );
  }
}

/// Botón compacto y premium para abrir el detalle.
class DetailedButton extends StatelessWidget {
  const DetailedButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.brandPrimary,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: c.brandPrimary.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.brandPrimary)),
    );
  }
}

// ---------------------------------------------------------------------------
// Detalle de conectividad (modal premium)
// ---------------------------------------------------------------------------

void showConnectivityDetail(BuildContext context, ConnectivityRow row) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => _ConnectivityDetailDialog(row: row),
  );
}

class _ConnectivityDetailDialog extends StatelessWidget {
  const _ConnectivityDetailDialog({required this.row});
  final ConnectivityRow row;

  static const List<String> _days = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color accent = _statusColor(c, row.status);
    final List<List<bool>> grid = _grid();
    final int total = grid.fold(0, (s, d) => s + d.length);
    final int available = grid.fold(0, (s, d) => s + d.where((v) => v).length);
    final double percent = total == 0 ? 0 : available / total * 100;

    return Dialog(
      backgroundColor: c.surface,
      insetPadding: const EdgeInsets.all(Spacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Encabezado
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(Radii.md)),
                    child: Icon(Icons.storefront_outlined, color: accent),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(row.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            ChannelBadge(channel: row.channel, showLabel: false),
                            const SizedBox(width: Spacing.xs),
                            Flexible(
                              child: Text(
                                'Tienda ${row.storeId} · ${row.channel.label}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: row.status),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Motivo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.info_outline, size: 18, color: accent),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(row.detail, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Conectividad por día y hora', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        '${percent.toStringAsFixed(1)}% disponible',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.brandPrimary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text('Últimos 7 días · franjas de 1 hora', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: Spacing.md),
                  _Heatmap(days: _days, grid: grid),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: <Widget>[
                      _Legend(color: c.success, label: 'Disponible'),
                      const SizedBox(width: Spacing.md),
                      _Legend(color: c.surfaceAlt, label: 'Sin disponibilidad', bordered: true),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.power_settings_new, size: 16),
                    label: const Text('Cerrar tienda'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.bolt_outlined, size: 16),
                    label: const Text('Abrir tienda'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<List<bool>> _grid() {
    final Random rnd = Random(row.storeId.hashCode);
    return List<List<bool>>.generate(7, (day) {
      return List<bool>.generate(24, (hour) {
        final bool withinHours = hour >= 11 && hour < 22;
        if (row.status == StoreStatus.suspended || row.status == StoreStatus.closed) {
          return withinHours && rnd.nextDouble() > 0.85;
        }
        return withinHours && rnd.nextDouble() > 0.12;
      });
    });
  }

  static Color _statusColor(AppColors c, StoreStatus status) => switch (status) {
        StoreStatus.open => c.success,
        StoreStatus.paused => c.warning,
        StoreStatus.closed => c.danger,
        StoreStatus.suspended => c.suspended,
        StoreStatus.highDemand => c.brandPrimary,
      };
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.days, required this.grid});
  final List<String> days;
  final List<List<bool>> grid;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    const double cell = 11;
    const double gap = 2;
    const double labelWidth = 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Encabezado de horas
        Row(
          children: <Widget>[
            const SizedBox(width: labelWidth),
            for (int h = 0; h < 24; h++)
              Container(
                width: cell,
                margin: const EdgeInsets.only(right: gap),
                alignment: Alignment.bottomCenter,
                child: h % 6 == 0
                    ? Text('$h', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9))
                    : const SizedBox.shrink(),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (int d = 0; d < days.length; d++)
          Padding(
            padding: const EdgeInsets.only(bottom: gap),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: labelWidth,
                  child: Text(days[d], style: Theme.of(context).textTheme.labelSmall),
                ),
                for (int h = 0; h < 24; h++)
                  Tooltip(
                    message: '${days[d]} ${h.toString().padLeft(2, '0')}:00 · ${grid[d][h] ? 'Disponible' : 'Sin disponibilidad'}',
                    child: Container(
                      width: cell,
                      height: cell,
                      margin: const EdgeInsets.only(right: gap),
                      decoration: BoxDecoration(
                        color: grid[d][h] ? c.success.withValues(alpha: 0.85) : c.surfaceAlt,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: grid[d][h] ? Colors.transparent : c.border),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.bordered = false});
  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: bordered ? Border.all(color: c.border) : null,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
