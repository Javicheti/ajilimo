import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import '../branding/app_logo.dart';
import '../models/delivery.dart';
import '../widgets/app_card.dart';
import '../widgets/channel_badge.dart';
import '../widgets/kpi_card.dart';
import '../widgets/page_header.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';

/// Galería viva del design system. Se monta en la ruta `/design`.
class DesignGalleryPage extends StatelessWidget {
  const DesignGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        const PageHeader(title: 'Design System — AjíLimo', subtitle: 'Tokens, componentes y tipografía'),
        _Section(
          title: 'Marca',
          child: Wrap(
            spacing: Spacing.lg,
            runSpacing: Spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              AppLogo(size: 34),
              AppLogo(size: 52),
              AppLogo(size: 52, emblemOnly: true),
            ],
          ),
        ),
        const _Section(title: 'Estados de tienda', child: _StatusRow()),
        const _Section(title: 'Canales', child: _ChannelRow()),
        const _Section(title: 'KPIs', child: _KpiRow()),
        const _Section(title: 'Tipografía', child: _TypographyShowcase()),
        const _Section(title: 'Colores semánticos', child: _ColorShowcase()),
        const _Section(title: 'Botones y campos', child: _ControlsShowcase()),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(title: title),
        AppCard(child: child),
        const SizedBox(height: Spacing.lg),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: StoreStatus.values.map((s) => StatusChip(status: s)).toList(),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: DeliveryChannel.values.map((c) => ChannelBadge(channel: c)).toList(),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();
  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final int columns = w > 900 ? 4 : (w > 600 ? 2 : 1);
        const double gap = Spacing.md;
        final double itemWidth = (w - gap * (columns - 1)) / columns - Spacing.md;
        final kpis = <Widget>[
          KpiCard(label: 'Tiendas ON', value: '42/45', icon: Icons.storefront, accent: c.success),
          KpiCard(label: 'Pausadas', value: '2', icon: Icons.pause_circle, accent: c.warning),
          KpiCard(label: 'Suspendidas', value: '1', icon: Icons.block, accent: c.suspended),
          KpiCard(label: 'Reclamos (24h)', value: '4', icon: Icons.gavel, accent: c.danger),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: kpis
              .map((k) => SizedBox(width: itemWidth.clamp(160, double.infinity), child: k))
              .toList(),
        );
      },
    );
  }
}

class _TypographyShowcase extends StatelessWidget {
  const _TypographyShowcase();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Display · Montserrat', style: t.displayMedium),
        const SizedBox(height: Spacing.xs),
        Text('Headline · Montserrat', style: t.headlineMedium),
        const SizedBox(height: Spacing.xs),
        Text('Title · Montserrat', style: t.titleLarge),
        const SizedBox(height: Spacing.sm),
        Text('Body · Montserrat con cifras tabulares — S/ 12,340.50', style: t.bodyLarge),
        const SizedBox(height: Spacing.xxs),
        Text('Body small · Montserrat — texto secundario', style: t.bodySmall),
        const SizedBox(height: Spacing.xxs),
        Text('Label · Montserrat — 0123456789', style: t.labelMedium),
      ],
    );
  }
}

class _ColorShowcase extends StatelessWidget {
  const _ColorShowcase();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = <(String, Color)>[
      ('Marca', c.brandPrimary),
      ('Éxito', c.success),
      ('Alerta', c.warning),
      ('Peligro', c.danger),
      ('Suspendido', c.suspended),
      ('Info', c.info),
      ('Fondo', c.background),
      ('Superficie', c.surface),
      ('Borde', c.border),
    ];
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: items.map((e) => _Swatch(name: e.$1, color: e.$2)).toList(),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 96,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: context.colors.border),
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(name, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _ControlsShowcase extends StatelessWidget {
  const _ControlsShowcase();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: <Widget>[
            FilledButton(onPressed: () {}, child: const Text('Acción primaria')),
            OutlinedButton(onPressed: () {}, child: const Text('Secundaria')),
            TextButton(onPressed: () {}, child: const Text('Terciaria')),
          ],
        ),
        const SizedBox(height: Spacing.md),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Cooking time (min)',
            hintText: '22',
          ),
        ),
      ],
    );
  }
}
