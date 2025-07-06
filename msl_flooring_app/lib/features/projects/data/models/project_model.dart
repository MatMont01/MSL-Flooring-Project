// lib/features/projects/data/models/project_model.dart

import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.budget,
    required super.startDate,
    required super.endDate,
    required super.percentCompleted,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
    required super.updatedAt,
  });

  // --- FUNCIÓN DE AYUDA PARA PARSEAR FECHAS DE FORMA SEGURA ---
  static DateTime _parseDate(String dateString) {
    // Si la fecha no contiene 'T', es una fecha simple como '2025-06-01'
    if (!dateString.contains('T')) {
      return DateTime.parse(dateString);
    }
    // Si es una fecha completa, la normalizamos para que tenga 6 dígitos de microsegundos
    // si es necesario, para evitar errores de formato.
    return DateTime.parse(
      '${dateString.replaceAll('Z', '').padRight(26, '0')}Z',
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      budget: (json['budget'] as num).toDouble(),
      // Usamos nuestra función de ayuda segura
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      percentCompleted: (json['percentCompleted'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // Usamos nuestra función de ayuda segura
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}
