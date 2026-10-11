import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/tenant.dart';
import 'tenants_providers.dart';

class TenantsPage extends ConsumerStatefulWidget {
  const TenantsPage({super.key});

  @override
  ConsumerState<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends ConsumerState<TenantsPage> {
  Future<void> _createTenant() async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewTenantDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    ref.read(tenantsRepositoryProvider).add(name, TenantEnvironment.dev);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<Tenant> tenants = ref.watch(tenantsRepositoryProvider).all();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FilledButton.icon(
        onPressed: _createTenant,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Nuevo tenant'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView.separated(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: tenants.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const PageHeader(
                  icon: Icons.add_business_outlined,
                  eyebrow: 'Configuración',
                  title: 'Tenants',
                  subtitle: 'Negocios/organizaciones en la plataforma (SaaS)',
                );
              }
              final Tenant tenant = tenants[index - 1];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(tenant.name, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: Spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: c.brandSoft,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                          child: Text(
                            tenant.environment.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: c.brandPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text('slug: ${tenant.slug}', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      'secretos: ${tenant.secretNamespace}/...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textFaint),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewTenantDialog extends StatefulWidget {
  const _NewTenantDialog();

  @override
  State<_NewTenantDialog> createState() => _NewTenantDialogState();
}

class _NewTenantDialogState extends State<_NewTenantDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo tenant'),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del negocio', hintText: 'Ej. Pizzería Roma'),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
