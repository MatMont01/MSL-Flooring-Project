// lib/features/worker/domain/entities/check_in_request_entity.dart

class CheckInRequestEntity {
  final String workerId;
  final String projectId;
  final double latitude;
  final double longitude;

  const CheckInRequestEntity({
    required this.workerId,
    required this.projectId,
    required this.latitude,
    required this.longitude,
  });
}