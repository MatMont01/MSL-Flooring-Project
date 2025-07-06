// lib/features/inventory/domain/repositories/inventory_repository.dart

import '../entities/material_entity.dart';
import '../entities/material_request_entity.dart'; // Importa la nueva entidad
import '../entities/tool_entity.dart';

abstract class InventoryRepository {
  Future<List<MaterialEntity>> getAllMaterials();

  Future<List<ToolEntity>> getAllTools();

  // --- AÑADE ESTE NUEVO MÉTODO ---
  // Contrato para crear un nuevo material.
  // Devuelve la entidad del material recién creado.
  Future<MaterialEntity> createMaterial(MaterialRequestEntity material);
}
