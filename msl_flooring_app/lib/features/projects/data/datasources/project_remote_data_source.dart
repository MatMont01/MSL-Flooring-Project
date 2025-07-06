// lib/features/projects/data/datasources/project_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/project_model.dart';
import '../models/project_request_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getAllProjects();

  Future<List<ProjectModel>> getAssignedProjects();

  Future<ProjectModel> createProject(ProjectRequestModel project);

  Future<ProjectModel> getProjectById(String projectId);

  Future<List<String>> getWorkerIdsByProject(String projectId);

  Future<void> assignWorkerToProject(WorkerAssignmentRequestModel request);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    final url = ApiConstants.projectServiceBaseUrl;
    print('[ProjectDataSource] Calling GET $url');
    final response = await _apiClient.get(
      ApiConstants.projectServiceBaseUrl,
      '',
    );
    final List<dynamic> projectListJson = response;
    return projectListJson.map((json) => ProjectModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProjectModel>> getAssignedProjects() async {
    final url = '${ApiConstants.projectServiceBaseUrl}/my-assigned';
    print('[ProjectDataSource] Calling GET $url');
    final response = await _apiClient.get(
      ApiConstants.projectServiceBaseUrl,
      '/my-assigned',
    );
    final List<dynamic> projectListJson = response;
    return projectListJson.map((json) => ProjectModel.fromJson(json)).toList();
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<ProjectModel> createProject(ProjectRequestModel project) async {
    final url = ApiConstants.projectServiceBaseUrl;
    print('[ProjectDataSource] Calling POST $url');

    final response = await _apiClient.post(
      ApiConstants.projectServiceBaseUrl,
      '', // El endpoint POST está en la raíz, según tu controller
      project.toJson(), // Usamos el método toJson() para el cuerpo
    );

    // La API devuelve el proyecto recién creado como un solo objeto JSON
    return ProjectModel.fromJson(response);
  }

  @override
  Future<ProjectModel> getProjectById(String projectId) async {
    final endpoint = '/$projectId';
    final url = '${ApiConstants.projectServiceBaseUrl}$endpoint';
    print('[ProjectDataSource] Calling GET $url');
    final response = await _apiClient.get(
      ApiConstants.projectServiceBaseUrl,
      endpoint,
    );
    return ProjectModel.fromJson(response);
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<List<String>> getWorkerIdsByProject(String projectId) async {
    // Construimos el endpoint, ej: /projects/123-abc/workers
    final endpoint = '/$projectId/workers';
    final url = '${ApiConstants.projectServiceBaseUrl}$endpoint';
    print('[ProjectDataSource] Calling GET $url');

    final response = await _apiClient.get(
      ApiConstants.projectServiceBaseUrl,
      endpoint,
    );

    // La API devuelve una lista de UUIDs en formato String.
    // La respuesta (response) ya es una List<dynamic>, la convertimos a List<String>.
    final List<String> workerIds = List<String>.from(response);
    return workerIds;
  }

  @override
  Future<void> assignWorkerToProject(
    WorkerAssignmentRequestModel request,
  ) async {
    await _apiClient.post(
      ApiConstants.projectServiceBaseUrl,
      '/assign-worker', // El endpoint de asignación
      request.toJson(), // El cuerpo de la petición
    );
  }
}
