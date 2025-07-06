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
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _apiClient;

  InventoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<InventoryItemModel>> getAllItems() async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '',
    );
    final List<dynamic> itemListJson = response;
    return itemListJson
        .map((json) => InventoryItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<InventoryItemModel>> getItemsByProject(String projectId) async {
    final response = await _apiClient.get(
      ApiConstants.inventoryServiceBaseUrl,
      '/project/$projectId',
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
      '/$itemId',
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<InventoryItemModel> createItem(InventoryItemModel item) async {
    final response = await _apiClient.post(
      ApiConstants.inventoryServiceBaseUrl,
      '',
      item.toJson(),
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<InventoryItemModel> updateItem(InventoryItemModel item) async {
    final response = await _apiClient.put(
      ApiConstants.inventoryServiceBaseUrl,
      '/${item.id}',
      item.toJson(),
    );
    return InventoryItemModel.fromJson(response);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _apiClient.delete(ApiConstants.inventoryServiceBaseUrl, '/$itemId');
  }
}
