// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:msl_flooring_app/core/common_widgets/session_handler.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/inventory/presentation/screens/create_material_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart'
    as projects;
import '../../features/worker/presentation/screens/worker_list_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/documents/presentation/screens/upload_document_screen.dart';
import '../../features/documents/presentation/screens/document_permissions_screen.dart';
import 'app_routes.dart';

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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SessionHandler(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const projects.ProjectListScreen(),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.inventory,
                builder: (context, state) => const InventoryScreen(),
                routes: [
                  GoRoute(
                    path: 'create-material',
                    builder: (context, state) => const CreateMaterialScreen(),
                  ),
                ],
              ),
            ],
          ),
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
                path: '/documents',
                builder: (context, state) => const DocumentsScreen(),
                routes: [
                  GoRoute(
                    path: 'upload',
                    builder: (context, state) => const UploadDocumentScreen(),
                  ),
                  GoRoute(
                    path: 'permissions',
                    builder: (context, state) =>
                        const DocumentPermissionsScreen(),
                  ),
                  GoRoute(
                    path: 'permissions/:documentId',
                    builder: (context, state) {
                      final documentId = state.pathParameters['documentId']!;
                      return DocumentPermissionsScreen(documentId: documentId);
                    },
                  ),
                  GoRoute(
                    path: 'project/:projectId',
                    builder: (context, state) {
                      final projectId = state.pathParameters['projectId']!;
                      return DocumentsScreen(projectId: projectId);
                    },
                  ),
                ],
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
