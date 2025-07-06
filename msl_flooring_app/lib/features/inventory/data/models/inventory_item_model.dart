// lib/features/inventory/data/models/inventory_item_model.dart
import '../../domain/entities/inventory_item_entity.dart';

class InventoryItemModel extends InventoryItemEntity {
  const InventoryItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.category,
    super.projectId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      category: json['category'],
      projectId: json['projectId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'category': category,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}