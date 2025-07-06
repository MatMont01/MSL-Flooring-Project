// lib/features/inventory/domain/repositories/inventory_repository.dart

import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryItemEntity>> getAllItems();

  Future<List<InventoryItemEntity>> getItemsByProject(String projectId);

  Future<InventoryItemEntity> getItemById(String itemId);

  Future<InventoryItemEntity> createItem(InventoryItemEntity item);

  Future<InventoryItemEntity> updateItem(InventoryItemEntity item);

  Future<void> deleteItem(String itemId);

  // 🔧 NUEVO: Para asignaciones de materiales
  Future<void> createInventoryMovement(Map<String, dynamic> movementData);

  Future<List<Map<String, dynamic>>> getMovementsByMaterial(String materialId);

  Future<List<Map<String, dynamic>>> getMovementsByProject(String projectId);
}
