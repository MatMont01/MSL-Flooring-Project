// lib/features/projects/presentation/screens/project_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/project_providers.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectDetailsState = ref.watch(projectDetailsProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Proyecto')),
      body: Center(
        child: switch (projectDetailsState) {
          ProjectDetailsInitial() ||
          ProjectDetailsLoading() => const CircularProgressIndicator(),
          ProjectDetailsSuccess(project: final project) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(project.description),
                const SizedBox(height: 16),
                Text('Presupuesto: \$${project.budget.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(
                  'Fecha de inicio: ${DateFormat('yyyy-MM-dd').format(project.startDate)}',
                ),
                Text(
                  'Fecha de fin: ${DateFormat('yyyy-MM-dd').format(project.endDate)}',
                ),
                const SizedBox(height: 8),
                Text('Progreso: ${project.percentCompleted.toInt()}%'),
                const SizedBox(height: 8),
                Text('Ubicación: (${project.latitude}, ${project.longitude})'),
                const SizedBox(height: 8),
                Text(
                  'Creado: ${DateFormat('yyyy-MM-dd HH:mm').format(project.createdAt)}',
                ),
                Text(
                  'Actualizado: ${DateFormat('yyyy-MM-dd HH:mm').format(project.updatedAt)}',
                ),
              ],
            ),
          ),
          ProjectDetailsFailure(message: final message) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error al cargar detalles: $message'),
          ),
          ProjectDetailsState() => throw UnimplementedError(),
        },
      ),
    );
  }
}
