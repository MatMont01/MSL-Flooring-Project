// lib/core/api/api_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../error/failure.dart';

// Llave para guardar/leer el token
const String _authTokenKey = 'AUTH_TOKEN';

class ApiClient {
  final http.Client _client;
  final SharedPreferences _sharedPreferences;

  ApiClient({required SharedPreferences sharedPreferences, http.Client? client})
    : _sharedPreferences = sharedPreferences,
      _client = client ?? http.Client();

  // Método privado para obtener las cabeceras, incluyendo el token
  Map<String, String> _getHeaders() {
    final token = _sharedPreferences.getString(_authTokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Método GET ---
  Future<dynamic> get(String baseUrl, String endpoint) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client.get(uri, headers: _getHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(
        'No se pudo conectar a la red. Revisa tu conexión a internet.',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // --- Método POST ---
  Future<dynamic> post(
    String baseUrl,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure(
        'No se pudo conectar a la red. Revisa tu conexión a internet.',
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // --- Manejador de Respuestas ---
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      // La respuesta puede ser un objeto o una lista
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['message'] ?? 'Ocurrió un error en el servidor.';
      throw ServerFailure('Error ${response.statusCode}: $errorMessage');
    }
  }
}
