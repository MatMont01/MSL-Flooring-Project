// lib/features/worker/domain/repositories/worker_repository.dart

import '../entities/attendance_record_entity.dart';
import '../entities/check_in_request_entity.dart';
import '../entities/worker_entity.dart';

abstract class WorkerRepository {
  Future<List<WorkerEntity>> getAllWorkers();

  Future<List<WorkerEntity>> getWorkersByIds(List<String> workerIds);

  Future<AttendanceRecordEntity> checkIn(CheckInRequestEntity checkInData);

  Future<AttendanceRecordEntity> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
  });
  // Obtiene el registro de asistencia activo para un trabajador en un proyecto.
  // Puede devolver null si no hay ningún check-in activo.
  Future<AttendanceRecordEntity?> getActiveAttendanceRecord(String projectId);
}
