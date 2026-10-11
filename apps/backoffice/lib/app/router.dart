import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:go_router/go_router.dart';

import '../features/claims/presentation/claims_page.dart';
import '../features/control_tower/presentation/control_tower_page.dart';
import '../features/evidence/presentation/evidence_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/promos/presentation/promos_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/settings/presentation/integrations_page.dart';
import '../features/tenants/presentation/tenants_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/control',
      name: 'control',
      builder: (context, state) => const ControlTowerPage(),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '/promos',
      name: 'promos',
      builder: (context, state) => const PromosPage(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/evidence',
      name: 'evidence',
      builder: (context, state) => const EvidencePage(),
    ),
    GoRoute(
      path: '/claims',
      name: 'claims',
      builder: (context, state) => const ClaimsPage(),
    ),
    GoRoute(
      path: '/design',
      name: 'design',
      builder: (context, state) => const DesignGalleryPage(),
    ),
    GoRoute(
      path: '/settings/integrations',
      name: 'integrations',
      builder: (context, state) => const IntegrationsPage(),
    ),
    GoRoute(
      path: '/settings/tenants',
      name: 'tenants',
      builder: (context, state) => const TenantsPage(),
    ),
  ],
);
