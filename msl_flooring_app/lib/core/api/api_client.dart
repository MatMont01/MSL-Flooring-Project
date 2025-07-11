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
    print('[ApiClient] Using token: ${token?.substring(0, 15)}...');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔧 NUEVO MÉTODO PARA UPLOAD DE ARCHIVOS
  Future<dynamic> uploadFile({
    required String baseUrl,
    required String endpoint,
    required File file,
    required String filename,
    required Map<String, String> fields,
    String fileFieldName = 'file',
  }) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making MULTIPART POST request to: $uri');

    try {
      // Crear multipart request
      var request = http.MultipartRequest('POST', uri);

      // 🔧 AÑADIR TOKEN DE AUTORIZACIÓN
      final token = _sharedPreferences.getString(_authTokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print('[ApiClient] Token added to multipart request');
      }

      // Añadir campos del formulario
      request.fields.addAll(fields);
      print('[ApiClient] Added fields: ${fields.keys.join(', ')}');

      // Añadir archivo
      var fileStream = http.ByteStream(file.openRead());
      var fileLength = await file.length();
      var multipartFile = http.MultipartFile(
        fileFieldName,
        fileStream,
        fileLength,
        filename: filename,
      );
      request.files.add(multipartFile);
      print('[ApiClient] Added file: $filename (${fileLength} bytes)');

      // Enviar request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('[ApiClient] Upload response status: ${response.statusCode}');
      print('[ApiClient] Upload response body: ${response.body}');

      return _handleResponse(response, uri.toString());
    } on SocketException {
      print('[ApiClient] Network Error: No connection for $uri');
      throw const NetworkFailure(
        'No se pudo conectar a la red. Revisa tu conexión a internet.',
      );
    } catch (e) {
      print('[ApiClient] Upload Error for $uri: $e');
      throw ServerFailure(e.toString());
    }
  }

  Future<dynamic> get(String baseUrl, String endpoint) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making GET request to: $uri');

    try {
      final response = await _client.get(uri, headers: _getHeaders());
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
    final Uri uri = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making POST request to: $uri');
    print('[ApiClient] POST Body: ${jsonEncode(body)}');

    try {
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

  // Manejador de respuestas con logs detallados
  dynamic _handleResponse(http.Response response, String url) {
    print(
      '[ApiClient] Response from $url - Status Code: ${response.statusCode}',
    );
    print('[ApiClient] Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        print('[ApiClient] Response body is empty, returning empty map.');
        return {};
      }
      try {
        final decodedJson = jsonDecode(response.body);
        print('[ApiClient] JSON decoded successfully.');
        return decodedJson;
      } catch (e) {
        print('[ApiClient] !!! JSON DECODING FAILED !!! Error: $e');
        throw const ServerFailure(
          'Error al procesar la respuesta del servidor (JSON malformado).',
        );
      }
    } else {
      print('[ApiClient] Request failed with status ${response.statusCode}.');

      String errorMessage = 'Error del servidor: ${response.statusCode}';

      // Intentar extraer mensaje de error del backend
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['message'] != null) {
          errorMessage = errorJson['message'];
        } else if (errorJson['error'] != null) {
          errorMessage = errorJson['error'];
        }
      } catch (e) {
        print('[ApiClient] Could not parse error response: $e');
      }

      throw ServerFailure(errorMessage);
    }
  }

  Future<dynamic> put(
    String baseUrl,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making PUT request to: $url');

    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: _getHeaders(),
    );

    return _handleResponse(response, url.toString());
  }

  Future<void> delete(String baseUrl, String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('[ApiClient] Making DELETE request to: $url');

    final response = await http.delete(url, headers: _getHeaders());

    if (response.statusCode == 204 || response.statusCode == 200) {
      print('[ApiClient] DELETE successful: ${response.statusCode}');
    } else {
      print('[ApiClient] DELETE failed: ${response.statusCode}');
      throw Exception('Failed to delete data');
    }
  }
}
