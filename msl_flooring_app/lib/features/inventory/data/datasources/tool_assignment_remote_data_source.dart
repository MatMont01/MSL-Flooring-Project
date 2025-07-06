// lib/features/inventory/data/datasources/tool_assignment_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';

abstract class ToolAssignmentRemoteDataSource {
  Future<void> createToolAssignment(Map<String, dynamic> assignmentData);

  Future<List<Map<String, dynamic>>> getAssignmentsByTool(String toolId);

  Future<List<Map<String, dynamic>>> getAssignmentsByWorker(String workerId);

  Future<List<Map<String, dynamic>>> getAssignmentsByProject(String projectId);
}

class ToolAssignmentRemoteDataSourceImpl
    implements ToolAssignmentRemoteDataSource {
  final ApiClient _apiClient;

  ToolAssignmentRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<void> createToolAssignment(Map<String, dynamic> assignmentData) async {
    await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/tool-assignments',
      assignmentData,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByTool(String toolId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tool-assignments/tool/$toolId',
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByWorker(
    String workerId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tool-assignments/worker/$workerId',
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByProject(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tool-assignments/project/$projectId',
    );
    return List<Map<String, dynamic>>.from(response);
  }
}
