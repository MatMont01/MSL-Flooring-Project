// lib/core/api/api_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../error/failure.dart';

const String _authTokenKey = 'AUTH_TOKEN';

class ApiClient {
  final http.Client _client;
  final SharedPreferences _sharedPreferences;

  ApiClient({required SharedPreferences sharedPreferences, http.Client? client})
    : _sharedPreferences = sharedPreferences,
      _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    final token = _sharedPreferences.getString(_authTokenKey);
    print(
      '[ApiClient] Using token: ${token?.substring(0, 15)}...',
    ); // Log para ver el token
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String baseUrl, String endpoint) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making GET request to: $uri');

    try {
      final response = await _client.get(uri, headers: _getHeaders());
      // LLamamos a nuestro nuevo manejador de respuestas
      return _handleResponse(response, uri.toString());
    } on SocketException {
      print('[ApiClient] Network Error: No connection for $uri');
      throw const NetworkFailure(
        'No se pudo conectar a la red. Revisa tu conexión a internet.',
      );
    } catch (e) {
      print('[ApiClient] Unknown Error for $uri: $e');
      throw ServerFailure(e.toString());
    }
  }

  Future<dynamic> post(String baseUrl, String endpoint, dynamic body) async {
    // Acepta 'dynamic'
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making POST request to: $uri');

    try {
      // jsonEncode puede manejar tanto Mapas como Listas
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response, uri.toString());
    } on SocketException {
      print('[ApiClient] Network Error: No connection for $uri');
      throw const NetworkFailure(
        'No se pudo conectar a la red. Revisa tu conexión a internet.',
      );
    } catch (e) {
      print('[ApiClient] Unknown Error for $uri: $e');
      throw ServerFailure(e.toString());
    }
  }

  // --- MANEJADOR DE RESPUESTAS CON LOGS ---
  dynamic _handleResponse(http.Response response, String url) {
    print(
      '[ApiClient] Response from $url - Status Code: ${response.statusCode}',
    );
    print(
      '[ApiClient] Response Body: ${response.body}',
    ); // ¡EL LOG MÁS IMPORTANTE!

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        print('[ApiClient] Response body is empty, returning empty map.');
        return {};
      }
      try {
        // Intentamos decodificar el JSON
        final decodedJson = jsonDecode(response.body);
        print('[ApiClient] JSON decoded successfully.');
        return decodedJson;
      } catch (e) {
        print('[ApiClient] !!! JSON DECODING FAILED !!! Error: $e');
        // Si falla la decodificación, lanzamos una falla para que el Notifier la atrape.
        throw const ServerFailure(
          'Error al procesar la respuesta del servidor (JSON malformado).',
        );
      }
    } else {
      // Si el código de estado no es exitoso
      print('[ApiClient] Request failed with status ${response.statusCode}.');
      final errorMessage = 'Error del servidor: ${response.statusCode}';
      throw ServerFailure(errorMessage);
    }
  }
}
