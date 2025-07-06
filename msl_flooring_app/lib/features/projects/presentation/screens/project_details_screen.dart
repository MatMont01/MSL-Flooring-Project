// lib/features/projects/presentation/screens/project_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/session_provider.dart';
import '../providers/project_providers.dart';
import '../widgets/assign_worker_dialog.dart';
import '../widgets/worker_attendance_widget.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

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
    final projectDetailsState = ref.watch(
      projectDetailsProvider(widget.projectId),
    );
    final assignedWorkersState = ref.watch(
      assignedWorkersProvider(widget.projectId),
    );
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Proyecto'),
        elevation: 0,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAssignWorkerDialog(context),
              tooltip: 'Asignar Trabajador',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectDetailsProvider(widget.projectId));
          ref.invalidate(assignedWorkersProvider(widget.projectId));
          await Future.delayed(const Duration(milliseconds: 100));
          ref
              .read(projectDetailsProvider(widget.projectId).notifier)
              .fetchProjectDetails(widget.projectId);
          ref
              .read(assignedWorkersProvider(widget.projectId).notifier)
              .fetchAssignedWorkers(widget.projectId);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: switch (projectDetailsState) {
            ProjectDetailsInitial() || ProjectDetailsLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircularProgressIndicator(),
              ),
            ),
            ProjectDetailsSuccess(project: final project) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información básica
                _buildProjectHeader(context, project),

                const SizedBox(height: 20),

                // Widget de asistencia para trabajadores (solo si no es admin)
                if (!isAdmin) ...[
                  WorkerAttendanceWidget(
                    projectId: widget.projectId,
                    projectLatitude: project.latitude.toDouble(),
                    projectLongitude: project.longitude.toDouble(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Información detallada
                _buildProjectDetails(context, project),

                const SizedBox(height: 20),

                // Progreso visual
                _buildProgressSection(context, project),

                const SizedBox(height: 20),

                // Trabajadores asignados (solo para admins)
                if (isAdmin) ...[
                  _buildAssignedWorkersSection(
                    context,
                    assignedWorkersState,
                    isAdmin,
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
            ProjectDetailsFailure(message: final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar detalles',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(
                          projectDetailsProvider(widget.projectId),
                        );
                        ref.invalidate(
                          assignedWorkersProvider(widget.projectId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
            ProjectDetailsState() => throw UnimplementedError(),
          },
        ),
      ),
    );
  }

  Widget _buildProjectHeader(BuildContext context, project) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderChip(
                  Icons.attach_money,
                  '\$${project.budget.toStringAsFixed(0)}',
                  Colors.white.withOpacity(0.2),
                ),
                const SizedBox(width: 12),
                _buildHeaderChip(
                  Icons.schedule,
                  '${project.percentCompleted.toInt()}%',
                  Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(BuildContext context, project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Proyecto',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today,
                'Fecha de Inicio',
                DateFormat('dd/MM/yyyy').format(project.startDate),
              ),
              _buildDetailRow(
                Icons.event,
                'Fecha de Fin',
                DateFormat('dd/MM/yyyy').format(project.endDate),
              ),
              _buildDetailRow(
                Icons.location_on,
                'Ubicación',
                '${project.latitude.toStringAsFixed(6)}, ${project.longitude.toStringAsFixed(6)}',
              ),
              _buildDetailRow(
                Icons.access_time,
                'Creado',
                DateFormat('dd/MM/yyyy HH:mm').format(project.createdAt),
              ),
              _buildDetailRow(
                Icons.update,
                'Actualizado',
                DateFormat('dd/MM/yyyy HH:mm').format(project.updatedAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, project) {
    final progress = project.percentCompleted / 100.0;
    final daysTotal = project.endDate.difference(project.startDate).inDays;
    final daysElapsed = DateTime.now().difference(project.startDate).inDays;
    final daysRemaining = project.endDate.difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso del Proyecto',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${project.percentCompleted.toInt()}% Completado',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    daysRemaining > 0
                        ? '$daysRemaining días restantes'
                        : daysRemaining == 0
                        ? 'Termina hoy'
                        : '${-daysRemaining} días de retraso',
                    style: TextStyle(
                      color: daysRemaining >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress < 0.5
                      ? Colors.red
                      : progress < 0.8
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressInfo('Total', '$daysTotal días'),
                  _buildProgressInfo('Transcurridos', '$daysElapsed días'),
                  _buildProgressInfo(
                    'Restantes',
                    '${daysRemaining > 0 ? daysRemaining : 0} días',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildAssignedWorkersSection(
    BuildContext context,
    assignedWorkersState,
    bool isAdmin,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trabajadores Asignados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAssignWorkerDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Asignar Trabajador'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              switch (assignedWorkersState) {
                AssignedWorkersInitial() ||
                AssignedWorkersLoading() => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                AssignedWorkersSuccess(workers: final workers) =>
                  workers.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No hay trabajadores asignados',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: workers
                              .map((worker) => _buildWorkerTile(worker))
                              .toList(),
                        ),
                AssignedWorkersFailure(message: final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Error: $message'),
                      ],
                    ),
                  ),
                ),
                AssignedWorkersState() => throw UnimplementedError(),
                // TODO: Handle this case.
                Object() => throw UnimplementedError(),
                // TODO: Handle this case.
                null => throw UnimplementedError(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerTile(worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            worker.firstName[0].toUpperCase(),
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          worker.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(worker.email),
        trailing: const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }

  void _showAssignWorkerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignWorkerDialog(projectId: widget.projectId),
    ).then((_) {
      ref
          .read(assignedWorkersProvider(widget.projectId).notifier)
          .fetchAssignedWorkers(widget.projectId);
    });
  }
}
