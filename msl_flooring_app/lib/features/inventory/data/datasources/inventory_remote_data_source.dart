// lib/features/inventory/data/datasources/inventory_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/inventory_item_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> getAllItems();

  Future<List<InventoryItemModel>> getItemsByProject(String projectId);

  Future<InventoryItemModel> getItemById(String itemId);

  Future<InventoryItemModel> createItem(InventoryItemModel item);

  Future<InventoryItemModel> updateItem(InventoryItemModel item);

  Future<void> deleteItem(String itemId);

  // 🔧 NUEVOS MÉTODOS para movimientos
  Future<void> createInventoryMovement(Map<String, dynamic> movementData);

  Future<List<Map<String, dynamic>>> getMovementsByMaterial(String materialId);

  Future<List<Map<String, dynamic>>> getMovementsByProject(String projectId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<InventoryItemModel>> getAllItems() async {
    print('🔍 [InventoryDataSource] Fetching all inventory items...');

    try {
      // Obtener materiales y herramientas en paralelo
      final results = await Future.wait([
        _apiClient.get(ApiConstants.inventoryServiceBaseUrl, '/materials'),
        _apiClient.get(ApiConstants.inventoryServiceBaseUrl, '/tools'),
      ]);

      final materialsJson = results[0] as List<dynamic>;
      final toolsJson = results[1] as List<dynamic>;

      print(
        '🔍 [InventoryDataSource] Materials: ${materialsJson.length}, Tools: ${toolsJson.length}',
      );

      // Convertir materiales
      final materials = materialsJson.map((json) {
        final Map<String, dynamic> materialMap = Map<String, dynamic>.from(
          json,
        );
        materialMap['category'] = 'Material';
        return InventoryItemModel.fromJson(materialMap);
      }).toList();

      // Convertir herramientas
      final tools = toolsJson.map((json) {
        final Map<String, dynamic> toolMap = Map<String, dynamic>.from(json);
        toolMap['category'] = 'Herramienta';
        toolMap['unitPrice'] =
            0.0; // Las herramientas no tienen precio en el backend
        return InventoryItemModel.fromJson(toolMap);
      }).toList();

      final allItems = [...materials, ...tools];
      print('🔍 [InventoryDataSource] Total items: ${allItems.length}');

      return allItems;
    } catch (e) {
      print('🔴 [InventoryDataSource] Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItemModel>> getItemsByProject(String projectId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/inventory-movements/project/$projectId',
    );
    final List<dynamic> itemListJson = response;
    return itemListJson
        .map((json) => InventoryItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<InventoryItemModel> getItemById(String itemId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/$itemId',
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<InventoryItemModel> createItem(InventoryItemModel item) async {
    final response = await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials',
      item.toJson(),
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<InventoryItemModel> updateItem(InventoryItemModel item) async {
    final response = await _apiClient.put(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/${item.id}',
      item.toJson(),
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _apiClient.delete(
      ApiConstants.inventoryServiceBaseUrl,
      '/materials/$itemId',
    );
  }

  // 🔧 NUEVOS MÉTODOS para movimientos de inventario
  @override
  Future<void> createInventoryMovement(
    Map<String, dynamic> movementData,
  ) async {
    await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '/inventory-movements',
      movementData,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMovementsByMaterial(
    String materialId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/inventory-movements/material/$materialId',
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getMovementsByProject(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/inventory-movements/project/$projectId',
    );
    return List<Map<String, dynamic>>.from(response);
  }
}
