// lib/features/auth/domain/entities/session_entity.dart

class SessionEntity {
  final String username;
  final List<String> roles;

  const SessionEntity({
    required this.username,
    required this.roles,
  });

  // --- GETTER CORREGIDO ---
  // Un helper para saber si el usuario es administrador.
  // Ahora es insensible a mayúsculas y minúsculas.
  bool get isAdmin {
    // Buscamos si alguno de los roles, convertido a minúsculas,
    // es igual a "administrador".
    return roles.any((role) => role.toLowerCase() == 'administrador');
  }
}