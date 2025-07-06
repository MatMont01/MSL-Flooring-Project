// lib/features/inventory/data/datasources/material_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/material_model.dart';
import '../models/material_request_model.dart';

abstract class MaterialRemoteDataSource {
  Future<List<MaterialModel>> getAllMaterials();

  Future<MaterialModel> getMaterialById(String materialId);

  Future<MaterialModel> createMaterial(MaterialRequestModel material);

  Future<MaterialModel> updateMaterial(
    String materialId,
    MaterialRequestModel material,
  );

  Future<void> deleteMaterial(String materialId);
}

class MaterialRemoteDataSourceImpl implements MaterialRemoteDataSource {
  final ApiClient _apiClient;

  MaterialRemoteDataSourceImpl({required ApiClient apiClient})
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
  Future<MaterialModel> getMaterialById(String materialId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/$materialId',
    );
    return MaterialModel.fromJson(response);
  }

  @override
  Future<MaterialModel> createMaterial(MaterialRequestModel material) async {
    final response = await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials',
      material.toJson(),
    );
    return MaterialModel.fromJson(response);
  }

  @override
  Future<MaterialModel> updateMaterial(
    String materialId,
    MaterialRequestModel material,
  ) async {
    final response = await _apiClient.put(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/$materialId',
      material.toJson(),
    );
    return MaterialModel.fromJson(response);
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    await _apiClient.delete(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/$materialId',
    );
  }
}
