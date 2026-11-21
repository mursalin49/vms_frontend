import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/vehicles/view/vehicle_form_screen.dart';
import '../features/vehicles/view/vehicle_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever the login state changes.
  final loggedIn = ValueNotifier<bool>(ref.read(authProvider).isLoggedIn);
  ref.listen<AuthState>(authProvider, (_, next) {
    loggedIn.value = next.isLoggedIn;
  });
  ref.onDispose(loggedIn.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: loggedIn,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final atLogin = state.matchedLocation == '/login';
      if (!isLoggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/vehicles',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: VehicleListScreen()),
          ),
          GoRoute(
            path: '/vehicles/new',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: VehicleFormScreen()),
          ),
          GoRoute(
            path: '/vehicles/:id/edit',
            pageBuilder: (_, state) => NoTransitionPage(
              child: VehicleFormScreen(
                vehicleId: int.tryParse(state.pathParameters['id'] ?? ''),
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
