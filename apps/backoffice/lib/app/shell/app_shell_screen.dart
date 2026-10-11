import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/claims/presentation/claims_providers.dart';
import '../../features/users/domain/app_user.dart';
import '../../features/users/domain/user_role.dart';
import '../../features/users/presentation/user_providers.dart';
import '../../core/theme/theme_provider.dart';

/// Shell autenticado: sidebar vertical + topbar + contenido de la ruta activa.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key, required this.currentRoute, required this.child});

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserRole role = ref.watch(currentRoleProvider);
    final AppUser? user = ref.watch(currentUserProvider).value;
    final int pendingClaims = ref.watch(pendingClaimsCountProvider);

    final String userName = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName
        : (user?.email ?? 'Invitado');

    return AppShell(
      title: _titleFor(currentRoute),
      currentRoute: currentRoute,
      groups: _groups(role, pendingClaims),
      onNavigate: (route) => context.go(route),
      userName: userName,
      userRoleLabel: role.label,
      notifications: pendingClaims,
      darkMode: ref.watch(themeModeProvider) == ThemeMode.dark,
      onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
      onLogout: () => ref.read(authServiceProvider)?.signOut(),
      child: child,
    );
  }

  List<NavGroup> _groups(UserRole role, int pendingClaims) {
    return <NavGroup>[
      NavGroup(
        label: 'Operación',
        entries: <NavEntry>[
          NavEntry(route: '/control', label: 'Torre de control', icon: Icons.grid_view_rounded),
          NavEntry(route: '/connectivity', label: 'Conectividad', icon: Icons.wifi_tethering),
          NavEntry(route: '/orders', label: 'Órdenes', icon: Icons.receipt_long_outlined),
          NavEntry(route: '/schedule', label: 'Horarios', icon: Icons.schedule_outlined),
          NavEntry(route: '/promos', label: 'Promos y sabores', icon: Icons.local_offer_outlined),
        ],
      ),
      NavGroup(
        label: 'Defensa',
        entries: <NavEntry>[
          NavEntry(route: '/claims', label: 'Reclamos', icon: Icons.gavel_outlined, badge: pendingClaims),
          NavEntry(route: '/evidence', label: 'Evidencia', icon: Icons.photo_camera_outlined),
        ],
      ),
      NavGroup(
        label: 'Analítica',
        entries: <NavEntry>[
          NavEntry(route: '/reports', label: 'Reportes', icon: Icons.bar_chart_outlined),
          NavEntry(route: '/financial', label: 'Financiero', icon: Icons.account_balance_wallet_outlined),
        ],
      ),
      NavGroup(
        label: 'Configuración',
        entries: <NavEntry>[
          NavEntry(route: '/settings/integrations', label: 'Integraciones', icon: Icons.hub_outlined),
          if (role.can(Permission.manageUsers))
            NavEntry(route: '/settings/users', label: 'Usuarios', icon: Icons.manage_accounts_outlined),
          if (role.can(Permission.manageTenants))
            NavEntry(route: '/settings/tenants', label: 'Tenants', icon: Icons.add_business_outlined),
        ],
      ),
      const NavGroup(
        label: 'Sistema',
        entries: <NavEntry>[
          NavEntry(route: '/design', label: 'Design system', icon: Icons.palette_outlined),
        ],
      ),
    ];
  }

  String _titleFor(String route) {
    if (route.startsWith('/control')) return 'Torre de control';
    if (route.startsWith('/connectivity')) return 'Conectividad';
    if (route.startsWith('/orders')) return 'Órdenes';
    if (route.startsWith('/schedule')) return 'Horarios';
    if (route.startsWith('/promos')) return 'Promos y sabores';
    if (route.startsWith('/claims')) return 'Reclamos';
    if (route.startsWith('/evidence')) return 'Evidencia';
    if (route.startsWith('/reports')) return 'Reportes';
    if (route.startsWith('/financial')) return 'Financiero';
    if (route.startsWith('/settings/integrations')) return 'Integraciones';
    if (route.startsWith('/settings/users')) return 'Usuarios y permisos';
    if (route.startsWith('/settings/tenants')) return 'Tenants';
    if (route.startsWith('/design')) return 'Design system';
    return 'AjíLimo';
  }
}
