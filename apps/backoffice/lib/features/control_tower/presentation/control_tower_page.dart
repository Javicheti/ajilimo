import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/control_tower_repository.dart';

class ControlTowerPage extends ConsumerStatefulWidget {
  const ControlTowerPage({super.key});

  @override
  ConsumerState<ControlTowerPage> createState() => _ControlTowerPageState();
}

class _ControlTowerPageState extends ConsumerState<ControlTowerPage> {
  DeliveryChannel? _channelFilter;
  late List<StoreStatusRow> _all;
  String? _brand;
  List<Map<String, dynamic>> _brands = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    final ControlTowerRepository repository = ref.read(controlTowerRepositoryProvider);
    _all = repository.seed();
    _initBrands(repository);
  }

  Future<void> _initBrands(ControlTowerRepository repository) async {
    try {
      final List<Map<String, dynamic>> brands = await ref.read(apiClientProvider).getBrands();
      if (mounted && brands.isNotEmpty) {
        setState(() {
          _brands = brands;
          _brand ??= brands.first['brandId'] as String?;
        });
      }
    } catch (_) {
      // sin marcas (modo local)
    }
    await _loadRemote(repository);
  }

  Future<void> _loadRemote(ControlTowerRepository repository) async {
    try {
      final List<StoreStatusRow> remote = await repository.fetchRemote(brand: _brand);
      if (!mounted || remote.isEmpty) return;
      setState(() => _all = remote);
    } catch (_) {
      // Sin BFF disponible: se mantienen los datos ficticios locales.
    }
  }

  void _onBrandChanged(String? brand) {
    setState(() => _brand = brand);
    _loadRemote(ref.read(controlTowerRepositoryProvider));
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
          icon: Icons.grid_view_rounded,
          eyebrow: 'Operación',
          title: 'Torre de control',
          subtitle: '${rows.length} tiendas · ${alerts.length} requieren atención',
          actions: <Widget>[
            if (_brands.isNotEmpty) _BrandSelector(brands: _brands, value: _brand, onChanged: _onBrandChanged),
          ],
        ),
        const SectionHeader(title: 'Métricas de servicio', subtitle: 'Últimos 7 días vs. periodo anterior'),
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          children: <Widget>[
            SizedBox(width: 210, child: KpiCard(label: 'Reclamos', value: '33.3%', icon: Icons.gavel_outlined, accent: c.danger, trend: 33.3)),
            SizedBox(width: 210, child: KpiCard(label: 'Cancelaciones', value: '0%', icon: Icons.cancel_outlined, accent: c.success, trend: 0)),
            SizedBox(width: 210, child: KpiCard(label: 'Disponibilidad', value: '38.8%', icon: Icons.wifi_tethering, accent: c.warning, trend: -0.8)),
            SizedBox(width: 210, child: KpiCard(label: 'Espera repartidor', value: '2:21', icon: Icons.timer_outlined, accent: c.info)),
          ],
        ),
        const SizedBox(height: Spacing.lg),
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
            padding: EdgeInsets.zero,
            child: alerts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text('Sin alertas.', style: Theme.of(context).textTheme.bodyMedium),
                  )
                : Column(
                    children: <Widget>[
                      for (int i = 0; i < alerts.length; i++) ...<Widget>[
                        _AlertRow(row: alerts[i]),
                        if (i < alerts.length - 1) Divider(height: 1, color: c.border),
                      ],
                    ],
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

class _BrandSelector extends StatelessWidget {
  const _BrandSelector({required this.brands, required this.value, required this.onChanged});
  final List<Map<String, dynamic>> brands;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.storefront_outlined, size: 16, color: c.textMid),
          const SizedBox(width: Spacing.xs),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            isDense: true,
            items: brands
                .map((b) => DropdownMenuItem<String>(
                      value: b['brandId'] as String,
                      child: Text('Marca: ${b['brandName']}'),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.row});
  final StoreStatusRow row;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color accent = switch (row.status) {
      StoreStatus.open => c.success,
      StoreStatus.paused => c.warning,
      StoreStatus.closed => c.danger,
      StoreStatus.suspended => c.suspended,
      StoreStatus.highDemand => c.brandPrimary,
    };

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(Radii.pill)),
            ),
            const SizedBox(width: Spacing.md),
            SizedBox(
              width: 190,
              child: Align(alignment: Alignment.centerLeft, child: StatusChip(status: row.status)),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(row.brand, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textMid)),
                ],
              ),
            ),
            ChannelBadge(channel: row.channel),
            const SizedBox(width: Spacing.sm),
            Icon(Icons.chevron_right, color: c.textFaint, size: 20),
          ],
        ),
      ),
    );
  }
}
