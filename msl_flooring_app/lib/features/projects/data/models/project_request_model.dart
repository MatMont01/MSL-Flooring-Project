// lib/features/projects/data/models/project_request_model.dart

import '../../domain/entities/project_request_entity.dart';

// Este modelo extiende la entidad para mantener la consistencia,
// aunque su propósito principal es la serialización a JSON.
class ProjectRequestModel extends ProjectRequestEntity {
  const ProjectRequestModel({
    required super.name,
    required super.description,
    required super.budget,
    required super.startDate,
    required super.endDate,
    required super.latitude,
    required super.longitude,
  });

  // Método para convertir el objeto a un mapa (que luego será JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'budget': budget,
      // Formateamos las fechas al formato 'YYYY-MM-DD' que la API espera
      'startDate': startDate.toIso8601String().substring(0, 10),
      'endDate': endDate.toIso8601String().substring(0, 10),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}