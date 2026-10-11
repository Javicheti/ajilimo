import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/claims/presentation/claims_page.dart';
import '../features/control_tower/presentation/control_tower_page.dart';
import '../features/evidence/presentation/evidence_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/promos/presentation/promos_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/settings/presentation/integrations_page.dart';
import '../features/tenants/presentation/tenants_page.dart';
import '../features/users/domain/app_user.dart';
import '../features/users/domain/user_role.dart';
import '../features/users/presentation/user_providers.dart';
import '../features/users/presentation/users_page.dart';
import 'shell/app_shell_screen.dart';

class _AuthRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

const String kDefaultRoute = '/control';

/// Router con redirección a `/login` sin sesión y shell con sidebar para el resto.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final _AuthRefresh refresh = _AuthRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen<AsyncValue<bool>>(authStatusProvider, (_, _) => refresh.refresh());
  ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (_, _) => refresh.refresh());

  return GoRouter(
    initialLocation: kDefaultRoute,
    refreshListenable: refresh,
    redirect: (context, state) {
      final bool signedIn = ref.read(authStatusProvider).value ?? true;
      final String location = state.matchedLocation;
      final bool atLogin = location == '/login';

      if (!signedIn) return atLogin ? null : '/login';
      if (atLogin) return kDefaultRoute;
      if (location == '/') return kDefaultRoute;

      final AppUser? user = ref.read(currentUserProvider).value;
      if (user != null) {
        if (location.startsWith('/settings/users') && !user.role.can(Permission.manageUsers)) {
          return kDefaultRoute;
        }
        if (location.startsWith('/settings/tenants') && !user.role.can(Permission.manageTenants)) {
          return kDefaultRoute;
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShellScreen(currentRoute: state.matchedLocation, child: child),
        routes: <RouteBase>[
          GoRoute(path: '/control', name: 'control', builder: (context, state) => const ControlTowerPage()),
          GoRoute(path: '/orders', name: 'orders', builder: (context, state) => const OrdersPage()),
          GoRoute(path: '/promos', name: 'promos', builder: (context, state) => const PromosPage()),
          GoRoute(path: '/reports', name: 'reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/evidence', name: 'evidence', builder: (context, state) => const EvidencePage()),
          GoRoute(path: '/claims', name: 'claims', builder: (context, state) => const ClaimsPage()),
          GoRoute(
            path: '/settings/integrations',
            name: 'integrations',
            builder: (context, state) => const IntegrationsPage(),
          ),
          GoRoute(
            path: '/settings/users',
            name: 'users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/settings/tenants',
            name: 'tenants',
            builder: (context, state) => const TenantsPage(),
          ),
          GoRoute(path: '/design', name: 'design', builder: (context, state) => const DesignGalleryPage()),
        ],
      ),
    ],
  );
});
