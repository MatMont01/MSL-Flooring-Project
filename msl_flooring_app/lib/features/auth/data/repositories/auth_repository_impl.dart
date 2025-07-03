// lib/features/1_auth/data/repositories/auth_repository_impl.dart

import '../../domain/repositories/auth_repository.dart';

import '../../../../core/error/failure.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      await remoteDataSource.login(username, password);
    } on Failure catch (e) {
      throw e; // Lanza la misma falla para que la capa de presentación la maneje.
    } catch (e) {
      // Para cualquier otro error inesperado.
      throw const ServerFailure('Ocurrió un error inesperado.');
    }
  }

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
