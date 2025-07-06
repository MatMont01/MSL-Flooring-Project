// lib/features/projects/presentation/widgets/assign_worker_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../worker/presentation/providers/worker_providers.dart';
import '../providers/project_providers.dart';

class AssignWorkerDialog extends ConsumerWidget {
  final String projectId;

  const AssignWorkerDialog({required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWorkersState = ref.watch(workerListProvider);
    final assignState = ref.watch(assignWorkerProvider);

    ref.listen<AssignWorkerState>(assignWorkerProvider, (previous, next) {
      if (next is AssignWorkerSuccess) {
        ref.invalidate(assignedWorkersProvider(projectId));
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trabajador asignado exitosamente')),
        );
      }
      if (next is AssignWorkerFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar: ${next.message}')),
        );
      }
    });

    return AlertDialog(
      title: const Text('Asignar Trabajador'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: switch (allWorkersState) {
          WorkerListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WorkerListSuccess(workers: final allWorkers) => ListView.builder(
            itemCount: allWorkers.length,
            itemBuilder: (context, index) {
              final worker = allWorkers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
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
                  title: Text(worker.fullName),
                  subtitle: Text(worker.email),
                  trailing: assignState is AssignWorkerLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  onTap: assignState is AssignWorkerLoading
                      ? null
                      : () {
                          ref
                              .read(assignWorkerProvider.notifier)
                              .assignWorker(
                                projectId: projectId,
                                workerId: worker.id,
                              );
                        },
                ),
              );
            },
          ),
          WorkerListFailure(message: final message) => Center(
            child: Text('Error al cargar trabajadores: $message'),
          ),
          _ => const Center(child: Text('Cargando trabajadores...')),
        },
      ),
      actions: [
        if (assignState is! AssignWorkerLoading)
          TextButton(
            onPressed: () {
              ref.read(assignWorkerProvider.notifier).resetState();
              context.pop();
            },
            child: const Text('Cancelar'),
          ),
      ],
    );
  }
}
