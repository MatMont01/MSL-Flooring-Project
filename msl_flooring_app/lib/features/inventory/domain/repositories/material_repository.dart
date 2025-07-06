// lib/features/inventory/domain/repositories/material_repository.dart

import '../entities/material_entity.dart';
import '../entities/material_request_entity.dart';

abstract class MaterialRepository {
  Future<List<MaterialEntity>> getAllMaterials();

  Future<MaterialEntity> getMaterialById(String materialId);

  Future<MaterialEntity> createMaterial(MaterialRequestEntity material);

  Future<MaterialEntity> updateMaterial(
    String materialId,
    MaterialRequestEntity material,
  );

  Future<void> deleteMaterial(String materialId);
}
