// lib/features/projects/data/repositories/project_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/project_request_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';
import '../models/project_request_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProjectEntity>> getAllProjects() async {
    try {
      return await remoteDataSource.getAllProjects();
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los proyectos.',
      );
    }
  }

  @override
  Future<List<ProjectEntity>> getAssignedProjects() async {
    try {
      return await remoteDataSource.getAssignedProjects();
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los proyectos asignados.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<ProjectEntity> createProject(ProjectRequestEntity project) async {
    try {
      // Creamos el modelo a partir de la entidad para poder usar toJson()
      final projectModel = ProjectRequestModel(
        name: project.name,
        description: project.description,
        budget: project.budget,
        startDate: project.startDate,
        endDate: project.endDate,
        latitude: project.latitude,
        longitude: project.longitude,
      );
      return await remoteDataSource.createProject(projectModel);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear el proyecto.',
      );
    }
  }

  @override
  Future<ProjectEntity> getProjectById(String projectId) async {
    try {
      return await remoteDataSource.getProjectById(projectId);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los detalles del proyecto.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<List<String>> getWorkerIdsByProject(String projectId) async {
    try {
      return await remoteDataSource.getWorkerIdsByProject(projectId);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los trabajadores del proyecto.',
      );
    }
  }

  @override
  Future<void> assignWorkerToProject({
    required String projectId,
    required String workerId,
  }) async {
    try {
      final requestModel = WorkerAssignmentRequestModel(
        projectId: projectId,
        workerId: workerId,
      );
      await remoteDataSource.assignWorkerToProject(requestModel);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al asignar el trabajador.',
      );
    }
  }
}
