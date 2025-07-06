// lib/features/inventory/data/repositories/inventory_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/material_request_entity.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';
import '../models/material_request_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MaterialEntity>> getAllMaterials() async {
    try {
      return await remoteDataSource.getAllMaterials();
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los materiales.',
      );
    }
  }

  @override
  Future<List<ToolEntity>> getAllTools() async {
    try {
      return await remoteDataSource.getAllTools();
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las herramientas.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<MaterialEntity> createMaterial(MaterialRequestEntity material) async {
    try {
      // Convertimos la entidad del dominio a un modelo de datos
      // para poder acceder al método toJson().
      final materialModel = MaterialRequestModel(
        name: material.name,
        description: material.description,
        imageUrl: material.imageUrl,
        unitPrice: material.unitPrice,
      );
      // Llamamos al datasource y devolvemos el resultado.
      return await remoteDataSource.createMaterial(materialModel);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear el material.',
      );
    }
  }
}
