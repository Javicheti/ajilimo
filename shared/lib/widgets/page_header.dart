import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';

/// Cabecera de página premium: ícono, eyebrow, título, subtítulo y acciones.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.icon,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[c.brandPrimary, c.brandPrimaryHover],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Radii.md),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: c.brandPrimary.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: Spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: c.brandPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                  ),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textMid),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(width: Spacing.md),
            Wrap(spacing: Spacing.sm, runSpacing: Spacing.xs, children: actions),
          ],
        ],
      ),
    );
  }
}
