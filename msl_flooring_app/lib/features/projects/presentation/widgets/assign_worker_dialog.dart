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
    // 1. Observamos el provider que nos da la lista de TODOS los trabajadores
    final allWorkersState = ref.watch(workerListProvider);
    // 2. Observamos el estado del PROCESO de asignación para mostrar un spinner
    final assignState = ref.watch(assignWorkerProvider);

    // 3. Escuchamos los cambios en el estado de la asignación para actuar en consecuencia
    ref.listen<AssignWorkerState>(assignWorkerProvider, (previous, next) {
      if (next is AssignWorkerSuccess) {
        // Si tiene éxito:
        // a) Invalidamos el provider de trabajadores asignados para que se refresque
        ref.invalidate(assignedWorkersProvider(projectId));
        // b) Cerramos el diálogo
        context.pop();
      }
      if (next is AssignWorkerFailure) {
        // Si falla, mostramos un error en un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar: ${next.message}')),
        );
      }
    });

    return AlertDialog(
      title: const Text('Asignar Trabajador'),
      content: SizedBox(
        width: double.maxFinite,
        // Usamos un switch para mostrar la lista de trabajadores o un indicador de carga/error
        child: switch (allWorkersState) {
          WorkerListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WorkerListSuccess(workers: final allWorkers) => ListView.builder(
            shrinkWrap: true,
            itemCount: allWorkers.length,
            itemBuilder: (context, index) {
              final worker = allWorkers[index];
              return ListTile(
                title: Text(worker.fullName),
                subtitle: Text(worker.email),
                onTap: () {
                  // Al tocar un trabajador, llamamos al notifier para asignarlo
                  ref
                      .read(assignWorkerProvider.notifier)
                      .assignWorker(projectId: projectId, workerId: worker.id);
                },
              );
            },
          ),
          WorkerListFailure(message: final message) => Text(
            'Error al cargar la lista de trabajadores: $message',
          ),
          _ => const Text('Cargando trabajadores...'),
        },
      ),
      actions: [
        // Si se está procesando una asignación, mostramos un spinner en lugar de los botones
        if (assignState is AssignWorkerLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          TextButton(
            onPressed: () {
              // Reseteamos el estado de asignación al cancelar y cerramos
              ref.read(assignWorkerProvider.notifier).resetState();
              context.pop();
            },
            child: const Text('Cancelar'),
          ),
      ],
    );
  }
}
