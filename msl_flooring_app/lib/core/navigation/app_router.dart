// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/core/common_widgets/home_shell.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';
import '../../features/worker/presentation/screens/worker_list_screen.dart';
import 'app_routes.dart';

// --- Router Configuration ---
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // --- Ruta Contenedora Principal (Shell Route) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          // --- Pestaña 0: Proyectos ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const ProjectListScreen(),
              ),
            ],
          ),
          // --- Pestaña 1: Inventario ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
            ],
          ),
          // --- Pestaña 2: Trabajadores ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workers',
                builder: (context, state) => const WorkerListScreen(),
              ),
            ],
          ),
          // --- Pestaña 3: Comunicaciones ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
          // --- Pestaña 4: Analíticas ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Ruta no encontrada: ${state.error?.message}')),
    ),
  );
}
