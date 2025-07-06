// lib/features/inventory/data/models/tool_request_model.dart

import '../../domain/entities/tool_request_entity.dart';

class ToolRequestModel extends ToolRequestEntity {
  const ToolRequestModel({
    required super.name,
    required super.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}