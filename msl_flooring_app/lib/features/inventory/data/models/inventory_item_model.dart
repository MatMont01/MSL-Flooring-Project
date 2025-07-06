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
    print('🔍 [InventoryItemModel] Parsing JSON: $json');

    return InventoryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'Sin descripción',
      // Si es material del backend, no tiene quantity, asumimos 1
      quantity: json['quantity'] as int? ?? 1,
      // El backend usa 'unitPrice' para materiales
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      // Diferenciamos entre materiales y herramientas
      category: json['category'] as String? ?? 'Material',
      projectId: json['projectId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitPrice': unitPrice,
      if (quantity != 1) 'quantity': quantity,
      if (projectId != null) 'projectId': projectId,
    };
  }
}
