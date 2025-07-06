// lib/features/worker/data/repositories/worker_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/attendance_record_entity.dart';
import '../../domain/entities/check_in_request_entity.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/worker_repository.dart';
import '../datasources/worker_remote_data_source.dart';
import '../models/check_in_request_model.dart';

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

  @override
  Future<List<WorkerEntity>> getWorkersByIds(List<String> workerIds) async {
    try {
      return await remoteDataSource.getWorkersByIds(workerIds);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los detalles de los trabajadores.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DE checkIn ---
  @override
  Future<AttendanceRecordEntity> checkIn(
    CheckInRequestEntity checkInData,
  ) async {
    try {
      // Convertimos la entidad del dominio a un modelo de datos
      final requestModel = CheckInRequestModel(
        workerId: checkInData.workerId,
        projectId: checkInData.projectId,
        latitude: checkInData.latitude,
        longitude: checkInData.longitude,
      );
      // Llamamos al datasource y devolvemos el resultado
      return await remoteDataSource.checkIn(requestModel);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al hacer check-in.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DE checkOut ---
  @override
  Future<AttendanceRecordEntity> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await remoteDataSource.checkOut(attendanceId, latitude, longitude);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al hacer check-out.',
      );
    }
  }
}
