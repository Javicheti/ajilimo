import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/claims/presentation/claims_page.dart';
import '../features/connectivity/presentation/connectivity_page.dart';
import '../features/control_tower/presentation/control_tower_page.dart';
import '../features/evidence/presentation/evidence_page.dart';
import '../features/financial/presentation/financial_page.dart';
import '../features/menu/presentation/menu_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/promos/presentation/promos_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/schedule/presentation/schedule_page.dart';
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

/// Transición suave (fade + slide) para las páginas del shell.
Page<void> _transition(GoRouterState state, Widget child) => CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondary, Widget child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.012), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      child: child,
    );

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
          GoRoute(path: '/control', name: 'control', pageBuilder: (context, state) => _transition(state, const ControlTowerPage())),
          GoRoute(path: '/connectivity', name: 'connectivity', pageBuilder: (context, state) => _transition(state, const ConnectivityPage())),
          GoRoute(path: '/orders', name: 'orders', pageBuilder: (context, state) => _transition(state, const OrdersPage())),
          GoRoute(path: '/schedule', name: 'schedule', pageBuilder: (context, state) => _transition(state, const SchedulePage())),
          GoRoute(path: '/menu', name: 'menu', pageBuilder: (context, state) => _transition(state, const MenuPage())),
          GoRoute(path: '/promos', name: 'promos', pageBuilder: (context, state) => _transition(state, const PromosPage())),
          GoRoute(path: '/reports', name: 'reports', pageBuilder: (context, state) => _transition(state, const ReportsPage())),
          GoRoute(path: '/financial', name: 'financial', pageBuilder: (context, state) => _transition(state, const FinancialPage())),
          GoRoute(path: '/evidence', name: 'evidence', pageBuilder: (context, state) => _transition(state, const EvidencePage())),
          GoRoute(path: '/claims', name: 'claims', pageBuilder: (context, state) => _transition(state, const ClaimsPage())),
          GoRoute(
            path: '/settings/integrations',
            name: 'integrations',
            pageBuilder: (context, state) => _transition(state, const IntegrationsPage()),
          ),
          GoRoute(
            path: '/settings/users',
            name: 'users',
            pageBuilder: (context, state) => _transition(state, const UsersPage()),
          ),
          GoRoute(
            path: '/settings/tenants',
            name: 'tenants',
            pageBuilder: (context, state) => _transition(state, const TenantsPage()),
          ),
          GoRoute(path: '/design', name: 'design', pageBuilder: (context, state) => _transition(state, const DesignGalleryPage())),
        ],
      ),
    ],
  );
});
