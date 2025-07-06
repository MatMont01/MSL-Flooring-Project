// lib/features/worker/data/models/attendance_record_model.dart

import '../../domain/entities/attendance_record_entity.dart';

class AttendanceRecordModel extends AttendanceRecordEntity {
  const AttendanceRecordModel({
    required super.id,
    required super.workerId,
    required super.projectId,
    super.checkInTime,
    super.checkOutTime,
    super.latitude,
    super.longitude,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'],
      workerId: json['workerId'],
      projectId: json['projectId'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
