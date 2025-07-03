// lib/features/inventory/domain/repositories/inventory_repository.dart

import '../entities/material_entity.dart';
import '../entities/tool_entity.dart';

abstract class InventoryRepository {
  // Contrato para obtener una lista de todos los materiales.
  // Puede fallar, por lo que la implementación deberá manejar errores.
  Future<List<MaterialEntity>> getAllMaterials();

  // Contrato para obtener una lista de todas las herramientas.
  Future<List<ToolEntity>> getAllTools();
}