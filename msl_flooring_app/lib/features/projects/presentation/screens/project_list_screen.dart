// lib/features/projects/presentation/screens/project_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/core/providers/session_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../providers/project_providers.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectListProvider.notifier).fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectListProvider);

    // 1. Observamos el proveedor de sesión para saber el rol del usuario
    final sessionState = ref.watch(sessionProvider);
    final bool isAdmin = sessionState?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(projectListProvider.notifier).fetchProjects();
            },
          ),
        ],
      ),
      // 2. Añadimos el FloatingActionButton
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // Navegamos a la ruta de creación de proyectos
                // GoRouter entiende que debe ir a /projects/create
                context.push(
                  AppRoutes.createProject,
                ); // <-- MODIFICA ESTA LÍNEA
              },
              child: const Icon(Icons.add),
            )
          : null, // Si no es admin, el botón no se muestra (es nulo)
      body: Center(
        child: switch (projectsState) {
          ProjectListInitial() ||
          ProjectListLoading() => const CircularProgressIndicator(),
          ProjectListSuccess(projects: final projects) => RefreshIndicator(
            onRefresh: () async {
              await ref.read(projectListProvider.notifier).fetchProjects();
            },
            child: projects.isEmpty
                ? const Center(child: Text('No hay proyectos para mostrar.'))
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${project.percentCompleted.toInt()}%'),
                        ),
                        title: Text(project.name),
                        subtitle: Text(project.description),
                        onTap: () {
                          // Navegamos a la ruta de detalles, pasando el ID del proyecto.
                          // GoRouter construirá la URL /projects/{project.id}
                          // usamos context.push para apilar la pantalla
                          context.push('${AppRoutes.home}/${project.id}');
                        },
                      );
                    },
                  ),
          ),
          ProjectListFailure(message: final message) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(projectListProvider.notifier).fetchProjects();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
          // TODO: Handle this case.
          ProjectListState() => throw UnimplementedError(),
        },
      ),
    );
  }
}
