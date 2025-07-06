// lib/features/auth/presentation/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/providers/session_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Providers para la infraestructura de datos (VERSIÓN CORREGIDA) ---

// 1. Provider para SharedPreferences (se mantiene igual, es la fuente del Future)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

// 2. Provider para nuestro ApiClient. Ahora también depende del Future.
final apiClientProvider = Provider<ApiClient>((ref) {
  // Aquí usamos .requireValue para asegurarnos de que solo se construya
  // cuando SharedPreferences esté listo. Esto se maneja en la UI.
  final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
  return ApiClient(sharedPreferences: sharedPreferences, client: http.Client());
});

// 3. Provider para el AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
  return AuthRemoteDataSourceImpl(
    apiClient: apiClient,
    sharedPreferences: sharedPreferences,
  );
});

// 4. Provider para el AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Provider para la lógica de negocio (Notifier) ---

// 5. Provider del Notifier (se mantiene igual)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

// --- Clases de Estado (se mantienen igual) ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final SessionEntity session;

  AuthSuccess(this.session);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

// --- El Notifier (se mantiene igual) ---
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    try {
      state = AuthLoading();
      final session = await _authRepository.login(
        username: username,
        password: password,
      );
      _ref.read(sessionProvider.notifier).setSession(session);
      state = AuthSuccess(session);
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }
}
