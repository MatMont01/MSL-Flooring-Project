// lib/features/inventory/domain/entities/material_entity.dart

class MaterialEntity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // Puede ser nulo
  final double unitPrice;
  final DateTime createdAt;

  const MaterialEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.unitPrice,
    required this.createdAt,
  });
}
