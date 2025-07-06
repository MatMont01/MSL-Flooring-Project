// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importamos nuestro nuevo widget
import 'package:msl_flooring_app/core/common_widgets/session_handler.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/inventory/presentation/screens/create_material_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';

import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
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
      // --- Ruta Contenedora Principal (Shell Route) CORREGIDA ---
      StatefulShellRoute.indexedStack(
        // En lugar de devolver HomeShell directamente, usamos nuestro SessionHandler.
        builder: (context, state, navigationShell) {
          return SessionHandler(navigationShell: navigationShell);
        },
        branches: [
          // Pestaña 0: Proyectos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const ProjectListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateProjectScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final projectId = state.pathParameters['id']!;
                      return ProjectDetailsScreen(projectId: projectId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Pestaña 1: Inventario
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.inventory,
                builder: (context, state) => const InventoryScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.createMaterial,
                    builder: (context, state) => const CreateMaterialScreen(),
                  ),
                ],
              ),
            ],
          ),
          // El resto de las pestañas se mantienen igual
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workers',
                builder: (context, state) => const WorkerListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
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
