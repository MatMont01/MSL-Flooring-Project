// lib/features/projects/domain/repositories/project_repository.dart

import '../entities/project_entity.dart';

abstract class ProjectRepository {
  // Contrato para obtener una lista de todos los proyectos.
  // La implementación de este método en la capa de datos se encargará
  // de manejar cualquier posible error de red o del servidor.
  Future<List<ProjectEntity>> getAllProjects();
}
