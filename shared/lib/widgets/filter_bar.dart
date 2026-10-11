import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';

class FilterItem {
  const FilterItem({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;
}

/// Barra de filtros (Marca · Sucursales · Periodo) con acciones a la derecha.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    this.items = const <FilterItem>[],
    this.actions = const <Widget>[],
    this.trailing,
  });

  final List<FilterItem> items;
  final List<Widget> actions;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.tune, size: 18, color: c.textMid),
          const SizedBox(width: Spacing.xs),
          Text('Filtros', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: <Widget>[
                for (final FilterItem item in items) _FilterChip(item: item),
              ],
            ),
          ),
          ?trailing,
          for (final Widget action in actions) ...<Widget>[
            const SizedBox(width: Spacing.xs),
            action,
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.item});
  final FilterItem item;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (item.icon != null) ...<Widget>[
            Icon(item.icon, size: 14, color: c.textMid),
            const SizedBox(width: 4),
          ],
          Text('${item.label}: ', style: Theme.of(context).textTheme.labelSmall),
          Text(
            item.value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 16, color: c.textFaint),
        ],
      ),
    );
  }
}
