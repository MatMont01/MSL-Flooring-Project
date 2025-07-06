// lib/features/projects/presentation/screens/project_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- IMPORT NECESARIO ---
import '../../../../core/providers/session_provider.dart';
import '../providers/project_providers.dart';
import '../widgets/assign_worker_dialog.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({required this.projectId, super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectDetailsProvider(widget.projectId).notifier)
          .fetchProjectDetails(widget.projectId);
      ref
          .read(assignedWorkersProvider(widget.projectId).notifier)
          .fetchAssignedWorkers(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectDetailsProvider(widget.projectId));
    final workersState = ref.watch(assignedWorkersProvider(widget.projectId));

    // --- LÓGICA PARA VERIFICAR EL ROL ---
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: projectState is ProjectDetailsSuccess
            ? Text(projectState.project.name)
            : const Text('Detalles del Proyecto'),
      ),
      // --- BOTÓN FLOTANTE CONDICIONAL ---
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                // Mostramos el diálogo de asignación
                showDialog(
                  context: context,
                  builder: (_) =>
                      AssignWorkerDialog(projectId: widget.projectId),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Asignar Trabajador'),
            )
          : null, // Si no es admin, no se muestra nada.
      body: Center(
        child: switch (projectState) {
          ProjectDetailsInitial() ||
          ProjectDetailsLoading() => const CircularProgressIndicator(),
          ProjectDetailsSuccess(project: final project) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  'Presupuesto:',
                  '\$${NumberFormat("#,##0.00", "en_US").format(project.budget)}',
                ),
                _buildDetailRow(
                  'Progreso:',
                  '${project.percentCompleted.toStringAsFixed(1)}%',
                ),
                _buildDetailRow(
                  'Fecha de Inicio:',
                  DateFormat('dd/MM/yyyy').format(project.startDate),
                ),
                _buildDetailRow(
                  'Fecha de Fin:',
                  DateFormat('dd/MM/yyyy').format(project.endDate),
                ),

                // --- SECCIÓN: TRABAJADORES ASIGNADOS ---
                const Divider(height: 32),
                Text(
                  'Trabajadores Asignados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                switch (workersState) {
                  AssignedWorkersLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  AssignedWorkersSuccess(workers: final workers) =>
                    workers.isEmpty
                        ? const Text(
                            'No hay trabajadores asignados a este proyecto.',
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: workers.length,
                            itemBuilder: (context, index) {
                              final worker = workers[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(worker.firstName[0]),
                                  ),
                                  title: Text(worker.fullName),
                                  subtitle: Text(worker.email),
                                ),
                              );
                            },
                          ),
                  AssignedWorkersFailure(message: final message) => Text(
                    'Error al cargar trabajadores: $message',
                  ),
                  _ => const SizedBox.shrink(),
                },
              ],
            ),
          ),
          ProjectDetailsFailure(message: final message) => Text(
            'Error: $message',
          ),
          // TODO: Handle this case.
          ProjectDetailsState() => throw UnimplementedError(),
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
