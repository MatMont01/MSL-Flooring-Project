// lib/features/inventory/data/datasources/inventory_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/material_model.dart';
import '../models/material_request_model.dart'; // Importa el nuevo modelo
import '../models/tool_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<MaterialModel>> getAllMaterials();

  Future<List<ToolModel>> getAllTools();

  // --- AÑADE ESTE NUEVO MÉTODO ---
  Future<MaterialModel> createMaterial(MaterialRequestModel material);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<MaterialModel>> getAllMaterials() async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials',
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
      '/tools',
    );
    final List<dynamic> toolListJson = response;
    return toolListJson.map((json) => ToolModel.fromJson(json)).toList();
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<MaterialModel> createMaterial(MaterialRequestModel material) async {
    final response = await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials', // El endpoint POST está en la raíz de materials
      material.toJson(), // Usamos el método toJson() para el cuerpo
    );

    // La API devuelve el material recién creado como un solo objeto JSON
    return MaterialModel.fromJson(response);
  }
}
