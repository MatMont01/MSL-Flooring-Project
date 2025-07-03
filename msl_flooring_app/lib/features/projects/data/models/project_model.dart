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

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      budget: (json['budget'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      percentCompleted: (json['percentCompleted'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
