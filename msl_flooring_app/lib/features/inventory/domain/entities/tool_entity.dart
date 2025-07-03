// lib/features/inventory/domain/entities/tool_entity.dart

class ToolEntity {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  const ToolEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });
}