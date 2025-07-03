// lib/features/inventory/data/models/tool_model.dart

import '../../domain/entities/tool_entity.dart';

class ToolModel extends ToolEntity {
  const ToolModel({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
