import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/tenants/domain/tenant.dart';

void main() {
  test('slugify normaliza acentos, espacios y símbolos', () {
    expect(slugify('AjíLimo Perú'), 'ajilimo-peru');
    expect(slugify('  Pizzería Roma 2026 '), 'pizzeria-roma-2026');
    expect(slugify('Pollo & Más!!'), 'pollo-mas');
  });

  test('secretNamespace se deriva del slug', () {
    const Tenant tenant = Tenant(
      id: 'x',
      name: 'X',
      slug: 'pizzeria-roma',
      environment: TenantEnvironment.dev,
    );
    expect(tenant.secretNamespace, 'tenants/pizzeria-roma');
  });
}
