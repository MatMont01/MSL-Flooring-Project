// lib/features/inventory/data/repositories/inventory_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';
import '../models/inventory_item_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InventoryItemEntity>> getAllItems() async {
    try {
      return await remoteDataSource.getAllItems();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los elementos del inventario.',
      );
    }
  }

  @override
  Future<List<InventoryItemEntity>> getItemsByProject(String projectId) async {
    try {
      return await remoteDataSource.getItemsByProject(projectId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los elementos del proyecto.',
      );
    }
  }

  @override
  Future<InventoryItemEntity> getItemById(String itemId) async {
    try {
      return await remoteDataSource.getItemById(itemId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener el elemento.',
      );
    }
  }

  @override
  Future<InventoryItemEntity> createItem(InventoryItemEntity item) async {
    try {
      final model = InventoryItemModel(
        id: item.id,
        name: item.name,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        category: item.category,
        projectId: item.projectId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
      return await remoteDataSource.createItem(model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear el elemento.',
      );
    }
  }

  @override
  Future<InventoryItemEntity> updateItem(InventoryItemEntity item) async {
    try {
      final model = InventoryItemModel(
        id: item.id,
        name: item.name,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        category: item.category,
        projectId: item.projectId,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
      return await remoteDataSource.updateItem(model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al actualizar el elemento.',
      );
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al eliminar el elemento.',
      );
    }
  }
}
