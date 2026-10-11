import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AjíLimo'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider)?.signOut(),
          ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.brandPrimary,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text('AjíLimo', style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Centro de control de delivery · multi-marca · multi-app · multi-local',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textMid),
                ),
                const SizedBox(height: Spacing.lg),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: const <Widget>[
                    ChannelBadge(channel: DeliveryChannel.rappi),
                    ChannelBadge(channel: DeliveryChannel.didi),
                    ChannelBadge(channel: DeliveryChannel.pedidosya),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => context.go('/design'),
                      icon: const Icon(Icons.palette_outlined),
                      label: const Text('Ver design system'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/settings/integrations'),
                      icon: const Icon(Icons.hub_outlined),
                      label: const Text('Integraciones'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/settings/tenants'),
                      icon: const Icon(Icons.add_business_outlined),
                      label: const Text('Tenants'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/control'),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Torre de control'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/orders'),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Órdenes'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/promos'),
                      icon: const Icon(Icons.local_offer_outlined),
                      label: const Text('Promos y sabores'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/reports'),
                      icon: const Icon(Icons.bar_chart_outlined),
                      label: const Text('Reportes'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/evidence'),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Evidencia'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/claims'),
                      icon: const Icon(Icons.gavel_outlined),
                      label: const Text('Reclamos'),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Centro de control', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Torre de control, órdenes, promos, reportes, evidencia y reclamos. '
                        'Funciona con datos de prueba locales; listo para credenciales reales.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
