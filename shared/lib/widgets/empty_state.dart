import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';

/// Estado vacío con ícono, título, mensaje y acción opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: c.textFaint),
            ),
            const SizedBox(height: Spacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...<Widget>[
              const SizedBox(height: Spacing.xs),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textMid),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: Spacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
