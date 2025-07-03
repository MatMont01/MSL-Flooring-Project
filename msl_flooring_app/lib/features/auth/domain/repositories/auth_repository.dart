// lib/features/1_auth/domain/repositories/auth_repository.dart

import '../../../../core/error/failure.dart';

// Este es el contrato que la capa de datos deberá implementar.
abstract class AuthRepository {
  // El método de login. Puede fallar, por lo que podría lanzar una 'Failure'.
  // Si tiene éxito, no devuelve nada, pero internamente guardará el token.
  Future<void> login({required String username, required String password});

  // Método para el registro de un nuevo usuario.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  });

  // Método para cerrar sesión.
  Future<void> logout();
}
