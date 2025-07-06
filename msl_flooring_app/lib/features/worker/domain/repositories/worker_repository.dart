// lib/features/worker/domain/repositories/worker_repository.dart

import '../entities/attendance_record_entity.dart';
import '../entities/check_in_request_entity.dart';
import '../entities/worker_entity.dart';

abstract class WorkerRepository {
  Future<List<WorkerEntity>> getAllWorkers();

  Future<List<WorkerEntity>> getWorkersByIds(List<String> workerIds);

  // --- AÑADE ESTOS NUEVOS MÉTODOS ---

  // Realiza el check-in y devuelve el registro de asistencia creado.
  Future<AttendanceRecordEntity> checkIn(CheckInRequestEntity checkInData);

  // Realiza el check-out y devuelve el registro de asistencia actualizado.
  Future<AttendanceRecordEntity> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
  });
}
