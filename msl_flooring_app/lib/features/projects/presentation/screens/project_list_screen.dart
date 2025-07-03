// lib/features/projects/presentation/screens/project_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_providers.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del provider de la lista de proyectos
    final projectsState = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proyectos')),
      body: Center(
        // Usamos un switch para reaccionar a los cambios de estado
        child: switch (projectsState) {
          ProjectListInitial() ||
          ProjectListLoading() => const CircularProgressIndicator(),
          ProjectListSuccess(projects: final projects) => ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${project.percentCompleted.toInt()}%'),
                ),
                title: Text(project.name),
                subtitle: Text(project.description),
              );
            },
          ),
          ProjectListFailure(message: final message) => Text('Error: $message'),
          // TODO: Handle this case.
          ProjectListState() => throw UnimplementedError(),
        },
      ),
    );
  }
}
