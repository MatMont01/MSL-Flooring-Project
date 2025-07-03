// lib/features/auth/presentation/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Providers para la infraestructura de datos ---

// 1. Provider para SharedPreferences (lo usaremos para el token)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// 2. Provider para nuestro ApiClient (versión corregida y única)
final apiClientProvider = Provider<ApiClient>((ref) {
  // Obtenemos SharedPreferences de forma segura
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return ApiClient(sharedPreferences: sharedPreferences, client: http.Client());
});

// 3. Provider para el AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData!.value;
  return AuthRemoteDataSourceImpl(
    apiClient: apiClient,
    sharedPreferences: sharedPreferences,
  );
});

// 4. Provider para el AuthRepository (el que usará nuestra UI)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Provider para la lógica de negocio (Notifier) ---

// 5. Provider del Notifier que manejará el estado de la autenticación
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// --- Clases de Estado ---

// 6. Definimos los posibles estados de nuestra pantalla de login
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

// --- El Notifier ---

// 7. Esta es la clase que contiene la lógica para llamar al repositorio
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    try {
      state = AuthLoading(); // Cambiamos el estado a "cargando"
      await _authRepository.login(username: username, password: password);
      state = AuthSuccess(); // Si todo sale bien, estado de "éxito"
    } catch (e) {
      state = AuthFailure(e.toString()); // Si hay un error, estado de "falla"
    }
  }
}
