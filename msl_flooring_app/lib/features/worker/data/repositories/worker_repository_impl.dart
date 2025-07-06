// lib/features/worker/data/repositories/worker_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_remote_data_source.dart';

class WorkerRepositoryImpl implements WorkerRepository {
  final WorkerRemoteDataSource remoteDataSource;

  WorkerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WorkerEntity>> getAllWorkers() async {
    try {
      // Llama al método del datasource para obtener los datos.
      // El WorkerModel es compatible con WorkerEntity porque lo hereda.
      return await remoteDataSource.getAllWorkers();
    } on Failure {
      // Si el error ya es una de nuestras Fallas personalizadas, la relanzamos.
      rethrow;
    } catch (e) {
      // Si es cualquier otro tipo de error, lo envolvemos en una falla genérica.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los trabajadores.',
      );
    }
  }
}
