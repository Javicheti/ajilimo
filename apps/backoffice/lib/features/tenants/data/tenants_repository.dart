import '../domain/tenant.dart';

/// Repositorio de tenants. Fase 9: datos semilla (mock); en producción vendrá
/// de Firestore (control plane multi-tenant).
class TenantsRepository {
  final List<Tenant> _tenants = <Tenant>[
    const Tenant(
      id: 'ajilimo',
      name: 'AjíLimo (Operador)',
      slug: 'ajilimo',
      environment: TenantEnvironment.dev,
    ),
  ];

  List<Tenant> all() => List<Tenant>.unmodifiable(_tenants);

  Tenant add(String name, TenantEnvironment environment) {
    final String slug = slugify(name);
    final Tenant tenant = Tenant(
      id: slug,
      name: name.trim(),
      slug: slug,
      environment: environment,
    );
    _tenants.add(tenant);
    return tenant;
  }
}
