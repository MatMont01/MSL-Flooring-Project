// lib/features/auth/data/repositories/auth_repository_impl.dart

import '../../domain/entities/session_entity.dart'; // Importar
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/error/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SessionEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final jwtResponse = await remoteDataSource.login(username, password);
      return SessionEntity(
        id: jwtResponse.userId, // <-- AÑADE ESTA LÍNEA
        username: jwtResponse.username,
        roles: jwtResponse.roles,
      );
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure('Ocurrió un error inesperado.');
    }
  }

  // El resto de los métodos se mantienen igual
  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.register(username, email, password);
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw const ServerFailure('Ocurrió un error inesperado.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      throw const ServerFailure('Error al cerrar sesión.');
    }
  }
}
