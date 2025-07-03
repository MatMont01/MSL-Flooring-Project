// lib/features/inventory/data/datasources/inventory_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/material_model.dart';
import '../models/tool_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<MaterialModel>> getAllMaterials();

  Future<List<ToolModel>> getAllTools();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<MaterialModel>> getAllMaterials() async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials', // Endpoint para obtener materiales
    );

    final List<dynamic> materialListJson = response;
    return materialListJson
        .map((json) => MaterialModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ToolModel>> getAllTools() async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/tools', // Endpoint para obtener herramientas
    );

    final List<dynamic> toolListJson = response;
    return toolListJson.map((json) => ToolModel.fromJson(json)).toList();
  }
}
