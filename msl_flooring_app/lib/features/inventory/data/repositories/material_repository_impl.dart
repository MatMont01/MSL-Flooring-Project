// lib/features/inventory/data/repositories/material_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/material_request_entity.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/material_remote_data_source.dart';
import '../models/material_request_model.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialRemoteDataSource remoteDataSource;

  MaterialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MaterialEntity>> getAllMaterials() async {
    try {
      return await remoteDataSource.getAllMaterials();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los materiales.',
      );
    }
  }

  @override
  Future<MaterialEntity> getMaterialById(String materialId) async {
    try {
      return await remoteDataSource.getMaterialById(materialId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener el material.',
      );
    }
  }

  @override
  Future<MaterialEntity> createMaterial(MaterialRequestEntity material) async {
    try {
      final model = MaterialRequestModel(
        name: material.name,
        description: material.description,
        unitPrice: material.unitPrice,
      );
      return await remoteDataSource.createMaterial(model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear el material.',
      );
    }
  }

  @override
  Future<MaterialEntity> updateMaterial(
    String materialId,
    MaterialRequestEntity material,
  ) async {
    try {
      final model = MaterialRequestModel(
        name: material.name,
        description: material.description,
        unitPrice: material.unitPrice,
      );
      return await remoteDataSource.updateMaterial(materialId, model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al actualizar el material.',
      );
    }
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    try {
      await remoteDataSource.deleteMaterial(materialId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al eliminar el material.',
      );
    }
  }
}
