// lib/features/worker/data/models/check_in_request_model.dart

import '../../domain/entities/check_in_request_entity.dart';

class CheckInRequestModel extends CheckInRequestEntity {
  const CheckInRequestModel({
    required super.workerId,
    required super.projectId,
    required super.latitude,
    required super.longitude,
  });

  // Método para convertir el objeto a un mapa (que se convertirá en JSON)
  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'projectId': projectId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}