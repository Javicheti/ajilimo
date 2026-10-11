import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/control_tower_repository.dart';

class ControlTowerPage extends ConsumerStatefulWidget {
  const ControlTowerPage({super.key});

  @override
  ConsumerState<ControlTowerPage> createState() => _ControlTowerPageState();
}

class _ControlTowerPageState extends ConsumerState<ControlTowerPage> {
  DeliveryChannel? _channelFilter;
  late List<StoreStatusRow> _all;

  @override
  void initState() {
    super.initState();
    final ControlTowerRepository repository = ref.read(controlTowerRepositoryProvider);
    _all = repository.seed();
    _loadRemote(repository);
  }

  Future<void> _loadRemote(ControlTowerRepository repository) async {
    try {
      final List<StoreStatusRow> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _all = remote);
    } catch (_) {
      // Sin BFF disponible: se mantienen los datos ficticios locales.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<StoreStatusRow> all = _all;
    final List<StoreStatusRow> rows = _channelFilter == null
        ? all
        : all.where((r) => r.channel == _channelFilter).toList();

    int count(StoreStatus status) => rows.where((r) => r.status == status).length;
    final alerts = rows.where((r) => r.status != StoreStatus.open).toList();

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        PageHeader(
          title: 'Torre de control',
          subtitle: '${rows.length} tiendas · ${alerts.length} requieren atención',
        ),
        Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: <Widget>[
              _kpi(context, 'Abiertas', count(StoreStatus.open), c.success, Icons.check_circle_outline),
              _kpi(context, 'Pausadas', count(StoreStatus.paused), c.warning, Icons.pause_circle_outline),
              _kpi(context, 'Suspendidas', count(StoreStatus.suspended), c.suspended, Icons.block),
              _kpi(context, 'Cerradas', count(StoreStatus.closed), c.danger, Icons.lock_outline),
              _kpi(context, 'Alta demanda', count(StoreStatus.highDemand), c.brandPrimary, Icons.local_fire_department),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(title: 'Resumen por app'),
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: DeliveryChannel.values.map((channel) {
              final List<StoreStatusRow> channelRows =
                  all.where((r) => r.channel == channel).toList();
              final int openCount = channelRows.where((r) => r.status == StoreStatus.open).length;
              return SizedBox(
                width: 220,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ChannelBadge(channel: channel),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        '$openCount / ${channelRows.length} abiertas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(
            title: 'Estado de tiendas',
            action: Wrap(
              spacing: Spacing.xs,
              children: <Widget>[
                FilterChip(
                  label: const Text('Todas'),
                  selected: _channelFilter == null,
                  onSelected: (_) => setState(() => _channelFilter = null),
                ),
                ...DeliveryChannel.values.map(
                  (channel) => FilterChip(
                    label: Text(channel.label),
                    selected: _channelFilter == channel,
                    onSelected: (_) => setState(() => _channelFilter = channel),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const double gap = Spacing.md;
              final int columns = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 760
                      ? 3
                      : constraints.maxWidth > 480
                          ? 2
                          : 1;
              final double itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: rows
                    .map((row) => SizedBox(width: itemWidth, child: _StoreCard(row: row)))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(
            title: 'Alertas',
            subtitle: '${alerts.length} tiendas requieren atención',
          ),
          AppCard(
            child: alerts.isEmpty
                ? Text('Sin alertas.', style: Theme.of(context).textTheme.bodyMedium)
                : Column(
                    children: alerts
                        .map(
                          (row) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: StatusChip(status: row.status, compact: true),
                            title: Text(row.name),
                            subtitle: Text(row.brand),
                            trailing: ChannelBadge(channel: row.channel),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      );
  }

  Widget _kpi(BuildContext context, String label, int value, Color accent, IconData icon) {
    return SizedBox(
      width: 190,
      child: KpiCard(label: label, value: '$value', icon: icon, accent: accent),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.row});
  final StoreStatusRow row;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  row.brand,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textMid),
                ),
              ),
              ChannelBadge(channel: row.channel, showLabel: false),
            ],
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            row.name,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.sm),
          StatusChip(status: row.status),
        ],
      ),
    );
  }
}
