import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import 'app_card.dart';

/// Tarjeta de KPI premium: ícono en chip, valor grande, etiqueta y tendencia opcional.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
    this.hint,
    this.trend,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;
  final String? hint;

  /// Variación porcentual (positivo/negativo).
  final double? trend;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = accent ?? c.brandPrimary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              const Spacer(),
              if (trend != null) _TrendChip(value: trend!),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Spacing.xxs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          if (hint != null) ...<Widget>[
            const SizedBox(height: Spacing.xxs),
            Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool up = value >= 0;
    final Color color = up ? c.success : c.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(up ? Icons.trending_up : Icons.trending_down, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${up ? '+' : ''}${value.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
