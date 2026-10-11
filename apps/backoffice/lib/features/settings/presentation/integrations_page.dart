import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/integrations_repository.dart';
import '../domain/integration.dart';
import 'integrations_providers.dart';

class IntegrationsPage extends ConsumerStatefulWidget {
  const IntegrationsPage({super.key});

  @override
  ConsumerState<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends ConsumerState<IntegrationsPage> {
  late List<Integration> _items;
  final Set<DeliveryChannel> _testing = <DeliveryChannel>{};

  @override
  void initState() {
    super.initState();
    final IntegrationsRepository repository = ref.read(integrationsRepositoryProvider);
    _items = List<Integration>.of(repository.seed());
    _loadRemote(repository);
  }

  Future<void> _loadRemote(IntegrationsRepository repository) async {
    try {
      final List<Integration> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _items = remote);
    } catch (_) {
      // Sin BFF disponible: se mantienen los datos ficticios locales.
    }
  }

  void _setEnvironment(int index, IntegrationEnvironment environment) {
    setState(() => _items[index] = _items[index].copyWith(environment: environment));
  }

  Future<void> _test(Integration integration) async {
    setState(() => _testing.add(integration.channel));
    final bool ok = await ref.read(integrationsRepositoryProvider).testConnection(integration);
    if (!mounted) return;
    setState(() => _testing.remove(integration.channel));
    final int index = _items.indexWhere((i) => i.channel == integration.channel);
    setState(() {
      _items[index] = _items[index].copyWith(
        status: ok ? IntegrationStatus.connected : IntegrationStatus.error,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Conexión OK' : 'No se pudo conectar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración · Integraciones')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView.separated(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
            itemBuilder: (context, index) {
              final Integration integration = _items[index];
              return _IntegrationCard(
                integration: integration,
                testing: _testing.contains(integration.channel),
                onEnvironmentChanged: (env) => _setEnvironment(index, env),
                onTest: () => _test(integration),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.integration,
    required this.testing,
    required this.onEnvironmentChanged,
    required this.onTest,
  });

  final Integration integration;
  final bool testing;
  final ValueChanged<IntegrationEnvironment> onEnvironmentChanged;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ChannelBadge(channel: integration.channel),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(integration.channel.label, style: Theme.of(context).textTheme.titleMedium),
              ),
              _StatusPill(status: integration.status),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: <Widget>[
              SizedBox(
                width: 120,
                child: Text('Entorno', style: Theme.of(context).textTheme.labelMedium),
              ),
              DropdownButton<IntegrationEnvironment>(
                value: integration.environment,
                onChanged: (env) => env == null ? null : onEnvironmentChanged(env),
                items: IntegrationEnvironment.values
                    .map(
                      (env) => DropdownMenuItem<IntegrationEnvironment>(
                        value: env,
                        child: Text(env.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xxs),
          _InfoRow(label: 'Base URL', value: integration.baseUrl),
          _InfoRow(
            label: 'Credenciales',
            value: integration.credentialsConfigured ? 'Configurado ✓' : 'Falta configurar',
            valueColor: integration.credentialsConfigured ? c.success : c.warning,
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: testing ? null : onTest,
                icon: testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(testing ? 'Probando…' : 'Probar conexión'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Carga de credenciales: disponible en Fase 2')),
                  );
                },
                icon: const Icon(Icons.key_outlined),
                label: const Text('Configurar credenciales'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final IntegrationStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = switch (status) {
      IntegrationStatus.connected => c.success,
      IntegrationStatus.error => c.danger,
      IntegrationStatus.pendingAuth => c.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
