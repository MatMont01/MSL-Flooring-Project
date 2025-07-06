// lib/features/projects/domain/repositories/project_repository.dart

import '../entities/project_entity.dart';
import '../entities/project_request_entity.dart'; // Importa la nueva entidad

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getAllProjects();

  Future<List<ProjectEntity>> getAssignedProjects();

  // --- AÑADE ESTE NUEVO MÉTODO ---
  // Contrato para crear un nuevo proyecto.
  // Devuelve el proyecto creado.
  Future<ProjectEntity> createProject(ProjectRequestEntity project);
}
