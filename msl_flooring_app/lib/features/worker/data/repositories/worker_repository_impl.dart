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
      return await remoteDataSource.getAllWorkers();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los trabajadores.',
      );
    }
  }

  @override
  Future<List<WorkerEntity>> getWorkersByIds(List<String> workerIds) async {
    try {
      return await remoteDataSource.getWorkersByIds(workerIds);
    } on Failure {
      rethrow;
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
    } on Failure {
      rethrow;
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
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al hacer check-out.',
      );
    }
  }

  // --- IMPLEMENTACIÓN DEL NUEVO MÉTODO ---
  @override
  Future<AttendanceRecordEntity?> getActiveAttendanceRecord(
    String projectId,
  ) async {
    try {
      // Simplemente pasamos la llamada al datasource.
      // El datasource ya maneja el caso de devolver null si hay un 404.
      return await remoteDataSource.getActiveAttendanceRecord(projectId);
    } on Failure {
      // Si es una falla que ya conocemos (diferente de 404), la relanzamos.
      rethrow;
    } catch (e) {
      // Para cualquier otro error inesperado.
      throw const ServerFailure(
        'Ocurrió un error al consultar el estado de la asistencia.',
      );
    }
  }
}
