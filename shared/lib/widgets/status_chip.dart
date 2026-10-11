import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import '../models/delivery.dart';

/// Chip de estado operativo (semáforo) con punto de color + etiqueta.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final StoreStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (Color color, TextStyle? style) = switch (status) {
      StoreStatus.open => (c.success, Theme.of(context).textTheme.labelMedium),
      StoreStatus.closed => (c.danger, Theme.of(context).textTheme.labelMedium),
      StoreStatus.paused => (c.warning, Theme.of(context).textTheme.labelMedium),
      StoreStatus.suspended => (c.suspended, Theme.of(context).textTheme.labelMedium),
      StoreStatus.highDemand => (c.brandPrimary, Theme.of(context).textTheme.labelMedium),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Spacing.xs : Spacing.sm,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            status.label,
            style: style?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
