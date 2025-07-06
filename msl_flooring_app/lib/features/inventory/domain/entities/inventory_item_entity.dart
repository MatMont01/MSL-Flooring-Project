// lib/features/inventory/domain/entities/inventory_item_entity.dart

class InventoryItemEntity {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;
  final String category;
  final String? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.category,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalValue => quantity * unitPrice;
}
