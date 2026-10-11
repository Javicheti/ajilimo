import 'package:go_router/go_router.dart';

import '../features/capture/presentation/korn_capture_page.dart';

final GoRouter kornRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'capture',
      builder: (context, state) => const KornCapturePage(),
    ),
  ],
);
