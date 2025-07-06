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
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  print('🔥 [AuthProviders] Creating SharedPreferences');
  return SharedPreferences.getInstance();
});

// 2. Provider para nuestro ApiClient. Ahora también depende del Future.
final apiClientProvider = Provider<ApiClient>((ref) {
  print('🔥 [AuthProviders] Creating ApiClient');
  try {
    final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
    print('🔥 [AuthProviders] ApiClient created successfully');
    return ApiClient(
      sharedPreferences: sharedPreferences,
      client: http.Client(),
    );
  } catch (e) {
    print('🔴 [AuthProviders] Error creating ApiClient: $e');
    rethrow;
  }
});

// 3. Provider para el AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  print('🔥 [AuthProviders] Creating AuthRemoteDataSource');
  try {
    final apiClient = ref.watch(apiClientProvider);
    final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
    print('🔥 [AuthProviders] AuthRemoteDataSource created successfully');
    return AuthRemoteDataSourceImpl(
      apiClient: apiClient,
      sharedPreferences: sharedPreferences,
    );
  } catch (e) {
    print('🔴 [AuthProviders] Error creating AuthRemoteDataSource: $e');
    rethrow;
  }
});

// 4. Provider para el AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  print('🔥 [AuthProviders] Creating AuthRepository');
  try {
    final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
    print('🔥 [AuthProviders] AuthRepository created successfully');
    return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  } catch (e) {
    print('🔴 [AuthProviders] Error creating AuthRepository: $e');
    rethrow;
  }
});

// --- Provider para la lógica de negocio (Notifier) ---

// 5. Provider del Notifier (se mantiene igual)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  print('🔥 [AuthProviders] Creating AuthNotifier');
  try {
    final authRepository = ref.watch(authRepositoryProvider);
    print('🔥 [AuthProviders] AuthNotifier created successfully');
    return AuthNotifier(authRepository, ref);
  } catch (e) {
    print('🔴 [AuthProviders] Error creating AuthNotifier: $e');
    rethrow;
  }
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
    print('🔥 [AuthNotifier] Starting login for user: $username');
    try {
      state = AuthLoading();
      print('🔥 [AuthNotifier] State set to Loading');

      final session = await _authRepository.login(
        username: username,
        password: password,
      );
      print('🔥 [AuthNotifier] Login successful, session: ${session.username}');

      _ref.read(sessionProvider.notifier).setSession(session);
      print('🔥 [AuthNotifier] Session set in provider');

      state = AuthSuccess(session);
      print('🔥 [AuthNotifier] State set to Success');
    } catch (e, stackTrace) {
      print('🔴 [AuthNotifier] Login failed: $e');
      print('🔴 [AuthNotifier] StackTrace: $stackTrace');
      state = AuthFailure(e.toString());
    }
  }
}
