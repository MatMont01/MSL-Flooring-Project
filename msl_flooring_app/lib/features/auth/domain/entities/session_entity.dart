// lib/features/auth/domain/entities/session_entity.dart

class SessionEntity {
  final String id; // <-- AÑADE ESTA LÍNEA
  final String username;
  final List<String> roles;

  const SessionEntity({
    required this.id, // <-- AÑADE ESTA LÍNEA
    required this.username,
    required this.roles,
  });

  bool get isAdmin =>
      roles.any((role) => role.toLowerCase() == 'administrador');
}
