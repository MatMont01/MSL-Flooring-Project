// lib/features/worker/domain/entities/attendance_record_entity.dart

class AttendanceRecordEntity {
  final String id;
  final String workerId;
  final String projectId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? latitude;
  final double? longitude;

  const AttendanceRecordEntity({
    required this.id,
    required this.workerId,
    required this.projectId,
    this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
  });
}