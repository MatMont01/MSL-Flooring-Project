// lib/features/inventory/data/repositories/inventory_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MaterialEntity>> getAllMaterials() async {
    try {
      // Llama al datasource para obtener los datos y los devuelve.
      // Como MaterialModel hereda de MaterialEntity, la conversión es implícita.
      return await remoteDataSource.getAllMaterials();
    } on Failure catch (e) {
      // Si el datasource lanza una Falla (ej. ServerFailure), la relanzamos.
      throw e;
    } catch (e) {
      // Para cualquier otro error inesperado, lanzamos una falla genérica.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los materiales.',
      );
    }
  }

  @override
  Future<List<ToolEntity>> getAllTools() async {
    try {
      // Llama al datasource para obtener la lista de herramientas.
      return await remoteDataSource.getAllTools();
    } on Failure catch (e) {
      // Relanzamos la falla para que la capa de presentación la maneje.
      throw e;
    } catch (e) {
      // Atrapamos cualquier otro error y lo envolvemos en nuestra Falla.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las herramientas.',
      );
    }
  }
}
