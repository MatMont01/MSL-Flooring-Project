// lib/features/worker/presentation/screens/worker_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/worker_providers.dart';

class WorkerListScreen extends ConsumerWidget {
  const WorkerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del provider de la lista de trabajadores
    final workersState = ref.watch(workerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trabajadores')),
      body: Center(
        // Usamos un switch para reaccionar a los cambios de estado
        child: switch (workersState) {
          WorkerListInitial() ||
          WorkerListLoading() => const CircularProgressIndicator(),
          WorkerListSuccess(workers: final workers) => ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(worker.firstName[0]), // Muestra la inicial
                ),
                title: Text(worker.fullName),
                // Usamos el getter que creamos
                subtitle: Text(worker.email),
              );
            },
          ),
          WorkerListFailure(message: final message) => Text('Error: $message'),
          // TODO: Handle this case.
          WorkerListState() => throw UnimplementedError(),
        },
      ),
    );
  }
}
