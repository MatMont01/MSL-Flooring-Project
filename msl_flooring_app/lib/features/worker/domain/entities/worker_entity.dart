// lib/features/worker/domain/entities/worker_entity.dart

class WorkerEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone; // Puede ser nulo
  final DateTime? dateHired; // Puede ser nulo
  final DateTime createdAt;

  const WorkerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.dateHired,
    required this.createdAt,
  });

  // Getter para obtener el nombre completo fácilmente
  String get fullName => '$firstName $lastName';
}
