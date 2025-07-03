// lib/features/projects/domain/entities/project_entity.dart

class ProjectEntity {
  final String id;
  final String name;
  final String description;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final double percentCompleted;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.percentCompleted,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });
}
