// lib/features/projects/domain/entities/project_request_entity.dart

class ProjectRequestEntity {
  final String name;
  final String description;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final double latitude;
  final double longitude;

  const ProjectRequestEntity({
    required this.name,
    required this.description,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.latitude,
    required this.longitude,
  });
}