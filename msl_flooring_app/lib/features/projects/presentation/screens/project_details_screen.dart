// lib/features/projects/presentation/screens/project_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../worker/presentation/providers/worker_providers.dart';
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
    // Usamos addPostFrameCallback para asegurarnos de que el widget esté listo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectId = widget.projectId;

      // --- ESTA ES LA ÚNICA SECCIÓN MODIFICADA ---
      // Simplemente iniciamos la carga de los datos necesarios para la pantalla.
      // La lógica de qué datos cargar según el rol ya está dentro de cada provider.

      // Iniciamos la carga de los detalles del proyecto.
      ref
          .read(projectDetailsProvider(projectId).notifier)
          .fetchProjectDetails(projectId);

      // Iniciamos la carga de los trabajadores asignados.
      ref
          .read(assignedWorkersProvider(projectId).notifier)
          .fetchAssignedWorkers(projectId);

      // NO necesitamos llamar a getStatus aquí, porque el attendanceProvider
      // lo hará automáticamente cuando la UI lo necesite por primera vez.
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectDetailsProvider(widget.projectId));
    final workersState = ref.watch(assignedWorkersProvider(widget.projectId));
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.isAdmin ?? false;

    // Observamos el provider de asistencia (esto ya estaba bien).
    // Esta línea es la que "despierta" al provider y hace que llame a getStatus.
    final attendanceState = ref.watch(attendanceProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectState is ProjectDetailsSuccess
            ? Text(projectState.project.name)
            : const Text('Detalles del Proyecto'),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      AssignWorkerDialog(projectId: widget.projectId),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Asignar Trabajador'),
            )
          : null,
      body: Center(
        child: switch (projectState) {
          ProjectDetailsInitial() ||
          ProjectDetailsLoading() => const CircularProgressIndicator(),
          ProjectDetailsSuccess(project: final project) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECCIÓN DE ASISTENCIA (SOLO PARA TRABAJADORES) ---
                if (!isAdmin) _buildAttendanceSection(context, attendanceState),

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

  Widget _buildAttendanceSection(BuildContext context, AttendanceState state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (state) {
          AttendanceInitial() || AttendanceLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          AttendanceSuccess(activeRecord: final record) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mi Asistencia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (record != null)
                Text(
                  'Check-in realizado a las: ${DateFormat.jm().format(record.checkInTime!)}',
                )
              else
                const Text('No has registrado tu entrada en este proyecto.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (record != null) {
                    ref
                        .read(attendanceProvider(widget.projectId).notifier)
                        .performCheckOut(record.id);
                  } else {
                    ref
                        .read(attendanceProvider(widget.projectId).notifier)
                        .performCheckIn(widget.projectId);
                  }
                },
                icon: Icon(record != null ? Icons.logout : Icons.login),
                label: Text(
                  record != null
                      ? 'Marcar Salida (Check-out)'
                      : 'Marcar Entrada (Check-in)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: record != null ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          AttendanceFailure(message: final message) => Text(
            'Error de asistencia: $message',
          ),
          // TODO: Handle this case.
          AttendanceState() => throw UnimplementedError(),
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
