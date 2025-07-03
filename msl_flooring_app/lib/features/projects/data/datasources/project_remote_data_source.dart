// lib/features/projects/data/datasources/project_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getAllProjects();
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final ApiClient _apiClient;

  ProjectRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    // Hacemos la llamada GET al endpoint de proyectos
    final response = await _apiClient.get(
      ApiConstants.projectServiceBaseUrl,
      '', // El endpoint es la raíz del servicio de proyectos
    );

    // La API devuelve una lista de objetos JSON
    final List<dynamic> projectListJson = response;

    // Mapeamos la lista de JSON a una lista de ProjectModel
    return projectListJson.map((json) => ProjectModel.fromJson(json)).toList();
  }
}
