/// Tipos de usuario (roles) de AjíLimo, ordenados por nivel de acceso.
enum UserRole { owner, superadmin, admin, supervisor, operator, viewer }

/// Permisos por módulo.
enum Permission {
  viewControlTower,
  actOrders,
  respondClaims,
  viewReports,
  captureEvidence,
  manageIntegrations,
  manageUsers,
  manageTenants,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.superadmin => 'Superadmin',
        UserRole.admin => 'Admin',
        UserRole.supervisor => 'Supervisor',
        UserRole.operator => 'Operador',
        UserRole.viewer => 'Solo lectura',
      };

  String get description => switch (this) {
        UserRole.owner => 'Dueño de la plataforma. Acceso total.',
        UserRole.superadmin => 'Administrador de la plataforma.',
        UserRole.admin => 'Administra su negocio (marcas, locales, usuarios).',
        UserRole.supervisor => 'Supervisa marcas/locales asignados.',
        UserRole.operator => 'Opera su local (órdenes, evidencia, reclamos).',
        UserRole.viewer => 'Solo visualiza.',
      };

  String get wire => name;

  Set<Permission> get permissions => switch (this) {
        UserRole.owner || UserRole.superadmin => Permission.values.toSet(),
        UserRole.admin => const <Permission>{
            Permission.viewControlTower,
            Permission.actOrders,
            Permission.respondClaims,
            Permission.viewReports,
            Permission.captureEvidence,
            Permission.manageIntegrations,
            Permission.manageUsers,
          },
        UserRole.supervisor => const <Permission>{
            Permission.viewControlTower,
            Permission.actOrders,
            Permission.respondClaims,
            Permission.viewReports,
            Permission.captureEvidence,
          },
        UserRole.operator => const <Permission>{
            Permission.viewControlTower,
            Permission.actOrders,
            Permission.respondClaims,
            Permission.captureEvidence,
          },
        UserRole.viewer => const <Permission>{
            Permission.viewControlTower,
            Permission.viewReports,
          },
      };

  bool can(Permission permission) => permissions.contains(permission);
}

extension PermissionX on Permission {
  String get label => switch (this) {
        Permission.viewControlTower => 'Ver torre de control',
        Permission.actOrders => 'Operar órdenes',
        Permission.respondClaims => 'Responder reclamos',
        Permission.viewReports => 'Ver reportes',
        Permission.captureEvidence => 'Capturar evidencia',
        Permission.manageIntegrations => 'Gestionar integraciones',
        Permission.manageUsers => 'Gestionar usuarios',
        Permission.manageTenants => 'Gestionar tenants',
      };
}

UserRole userRoleFromWire(String? value) => UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.viewer,
    );
