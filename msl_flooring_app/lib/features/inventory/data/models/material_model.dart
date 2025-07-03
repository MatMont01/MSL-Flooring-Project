// lib/features/inventory/data/models/material_model.dart

import '../../domain/entities/material_entity.dart';

class MaterialModel extends MaterialEntity {
  const MaterialModel({
    required super.id,
    required super.name,
    required super.description,
    super.imageUrl,
    required super.unitPrice,
    required super.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}