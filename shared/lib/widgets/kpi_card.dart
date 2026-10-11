import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import 'app_card.dart';

/// Tarjeta de KPI (indicador clave) para la torre de control.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
    this.hint,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;
  final String? hint;

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
              if (icon != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(Spacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          if (hint != null) ...<Widget>[
            const SizedBox(height: Spacing.xxs),
            Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
