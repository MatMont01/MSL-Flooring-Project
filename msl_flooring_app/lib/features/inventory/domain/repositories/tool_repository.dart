// lib/features/inventory/domain/repositories/tool_repository.dart

import '../entities/tool_entity.dart';
import '../entities/tool_request_entity.dart';

abstract class ToolRepository {
  Future<List<ToolEntity>> getAllTools();

  Future<ToolEntity> getToolById(String toolId);

  Future<ToolEntity> createTool(ToolRequestEntity tool);

  Future<ToolEntity> updateTool(String toolId, ToolRequestEntity tool);

  Future<void> deleteTool(String toolId);
}
