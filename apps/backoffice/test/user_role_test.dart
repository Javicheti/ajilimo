import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/users/domain/user_role.dart';

void main() {
  test('owner y superadmin tienen todos los permisos', () {
    expect(UserRole.owner.permissions.length, Permission.values.length);
    expect(UserRole.superadmin.can(Permission.manageTenants), true);
  });

  test('admin gestiona usuarios pero no tenants', () {
    expect(UserRole.admin.can(Permission.manageUsers), true);
    expect(UserRole.admin.can(Permission.manageTenants), false);
  });

  test('viewer solo ve torre y reportes', () {
    expect(UserRole.viewer.can(Permission.viewControlTower), true);
    expect(UserRole.viewer.can(Permission.viewReports), true);
    expect(UserRole.viewer.can(Permission.actOrders), false);
    expect(UserRole.viewer.can(Permission.manageUsers), false);
  });

  test('operator opera pero no gestiona', () {
    expect(UserRole.operator.can(Permission.actOrders), true);
    expect(UserRole.operator.can(Permission.respondClaims), true);
    expect(UserRole.operator.can(Permission.manageIntegrations), false);
  });

  test('userRoleFromWire mapea y hace fallback a viewer', () {
    expect(userRoleFromWire('admin'), UserRole.admin);
    expect(userRoleFromWire('desconocido'), UserRole.viewer);
    expect(userRoleFromWire(null), UserRole.viewer);
  });
}
