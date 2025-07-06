// lib/features/auth/domain/repositories/auth_repository.dart

import '../entities/session_entity.dart'; // Importar la nueva entidad

// Este es el contrato que la capa de datos deberá implementar.
abstract class AuthRepository {
  // El método de login ahora devuelve los datos de la sesión.
  Future<SessionEntity> login({
    required String username,
    required String password,
  });

  // El resto de los métodos se mantienen igual
  Future<void> register({
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();
}
