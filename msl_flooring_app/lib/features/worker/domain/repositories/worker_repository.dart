// lib/features/worker/domain/repositories/worker_repository.dart

import '../entities/worker_entity.dart';

abstract class WorkerRepository {
  // Contrato para obtener una lista de todos los trabajadores.
  // La implementación de este método se encargará de manejar
  // las posibles fallas (ej. error de red o del servidor).
  Future<List<WorkerEntity>> getAllWorkers();
}
