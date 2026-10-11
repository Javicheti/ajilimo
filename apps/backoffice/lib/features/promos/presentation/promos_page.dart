import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/promo.dart';
import 'promos_providers.dart';

class PromosPage extends ConsumerWidget {
  const PromosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final List<PromoItem> items = ref.read(promosRepositoryProvider).seed();

    int count(PromoState state) => items.where((i) => i.state == state).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: <Widget>[
                  _kpi(context, 'Activas', count(PromoState.active), c.success, Icons.check_circle_outline),
                  _kpi(context, 'Apagadas', count(PromoState.off), c.danger, Icons.power_settings_new),
                  _kpi(context, 'Suspendidas', count(PromoState.suspended), c.suspended, Icons.block),
                  _kpi(context, 'A precio full', count(PromoState.fullPrice), c.brandPrimary, Icons.sell_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              SectionHeader(title: 'Estado', subtitle: '${items.length} ítems monitoreados'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < items.length; i++) ...<Widget>[
                      _PromoRow(item: items[i]),
                      if (i < items.length - 1) Divider(height: 1, color: c.border),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpi(BuildContext context, String label, int value, Color accent, IconData icon) {
    return SizedBox(
      width: 200,
      child: KpiCard(label: label, value: '$value', icon: icon, accent: accent),
    );
  }
}

class _PromoRow extends StatelessWidget {
  const _PromoRow({required this.item});
  final PromoItem item;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color stateColor = switch (item.state) {
      PromoState.active => c.success,
      PromoState.off => c.danger,
      PromoState.suspended => c.suspended,
      PromoState.fullPrice => c.brandPrimary,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      leading: ChannelBadge(channel: item.channel, showLabel: false),
      title: Text(item.title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        '${item.type.label} · S/ ${item.price.toStringAsFixed(2)}'
        '${item.promoPrice != null ? ' (promo S/ ${item.promoPrice!.toStringAsFixed(2)})' : ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
        decoration: BoxDecoration(
          color: stateColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: stateColor.withValues(alpha: 0.35)),
        ),
        child: Text(
          item.state.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: stateColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
