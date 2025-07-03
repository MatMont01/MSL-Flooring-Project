// lib/features/1_auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/jwt_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRemoteDataSource {
  Future<JwtResponseModel> login(String username, String password);

  Future<void> register(String username, String email, String password);

  Future<void> logout();
}

const String _authTokenKey = 'AUTH_TOKEN';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final SharedPreferences _sharedPreferences;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required SharedPreferences sharedPreferences,
  }) : _apiClient = apiClient,
       _sharedPreferences = sharedPreferences;

  @override
  Future<JwtResponseModel> login(String username, String password) async {
    final body = {'username': username, 'password': password};

    final response = await _apiClient.post(
      ApiConstants.authServiceBaseUrl,
      ApiConstants.loginEndpoint,
      body,
    );

    final jwtResponse = JwtResponseModel.fromJson(response);

    // Guardamos el token de forma segura
    await _sharedPreferences.setString(_authTokenKey, jwtResponse.token);

    return jwtResponse;
  }

  @override
  Future<void> register(String username, String email, String password) async {
    final body = {'username': username, 'email': email, 'password': password};

    await _apiClient.post(
      ApiConstants.authServiceBaseUrl,
      ApiConstants.registerEndpoint,
      body,
    );
  }

  @override
  Future<void> logout() async {
    // Aquí podrías llamar al endpoint de logout de tu API si lo tuvieras implementado.
    // Por ahora, simplemente borraremos el token local.
    await _sharedPreferences.remove(_authTokenKey);
  }
}
