// lib/features/inventory/domain/entities/material_request_entity.dart

class MaterialRequestEntity {
  final String name;
  final String description;
  final String? imageUrl;
  final double unitPrice;

  const MaterialRequestEntity({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.unitPrice,
  });
}