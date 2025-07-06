// lib/features/inventory/data/datasources/tool_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/tool_model.dart';
import '../models/tool_request_model.dart';

abstract class ToolRemoteDataSource {
  Future<List<ToolModel>> getAllTools();

  Future<ToolModel> getToolById(String toolId);

  Future<ToolModel> createTool(ToolRequestModel tool);

  Future<ToolModel> updateTool(String toolId, ToolRequestModel tool);

  Future<void> deleteTool(String toolId);
}

class ToolRemoteDataSourceImpl implements ToolRemoteDataSource {
  final ApiClient _apiClient;

  ToolRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ToolModel>> getAllTools() async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools',
    );
    final List<dynamic> toolListJson = response;
    return toolListJson.map((json) => ToolModel.fromJson(json)).toList();
  }

  @override
  Future<ToolModel> getToolById(String toolId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools/$toolId',
    );
    return ToolModel.fromJson(response);
  }

  @override
  Future<ToolModel> createTool(ToolRequestModel tool) async {
    final response = await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools',
      tool.toJson(),
    );
    return ToolModel.fromJson(response);
  }

  @override
  Future<ToolModel> updateTool(String toolId, ToolRequestModel tool) async {
    final response = await _apiClient.put(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools/$toolId',
      tool.toJson(),
    );
    return ToolModel.fromJson(response);
  }

  @override
  Future<void> deleteTool(String toolId) async {
    await _apiClient.delete(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools/$toolId',
    );
  }
}
