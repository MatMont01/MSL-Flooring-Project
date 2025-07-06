// lib/features/inventory/domain/repositories/inventory_repository.dart
import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryItemEntity>> getAllItems();
  Future<List<InventoryItemEntity>> getItemsByProject(String projectId);
  Future<InventoryItemEntity> getItemById(String itemId);
  Future<InventoryItemEntity> createItem(InventoryItemEntity item);
  Future<InventoryItemEntity> updateItem(InventoryItemEntity item);
  Future<void> deleteItem(String itemId);
}