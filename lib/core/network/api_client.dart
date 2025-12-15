// ==================== core/network/api_client.dart ====================
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import 'api_endpoints.dart';

class ApiClient {
  final http.Client client;
  String? _token;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  // Setter para el token
  void setToken(String? token) {
    _token = token;
  }

  // Headers comunes
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client
          .get(uri, headers: _getHeaders(includeAuth: requiresAuth))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión HTTP');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

      final response = await client
          .post(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión HTTP');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

      final response = await client
          .put(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión HTTP');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // PATCH Request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

      final response = await client
          .patch(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión HTTP');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

      final response = await client
          .delete(uri, headers: _getHeaders(includeAuth: requiresAuth))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión HTTP');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  // Multipart Request (para imágenes)
  Future<Map<String, dynamic>> uploadMultipart(
    String endpoint,
    File file, {
    String fieldName = 'image',
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      if (requiresAuth && _token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Archivo
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException(message: 'Error al subir imagen: $e');
    }
  }

  // Manejo de respuestas
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      String errorMessage = 'Error del servidor';

      try {
        final errorBody = json.decode(response.body);
        errorMessage =
            errorBody['error']?['message'] ??
            errorBody['message'] ??
            'Error desconocido';
      } catch (e) {
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Error HTTP $statusCode';
      }

      throw ServerException(message: errorMessage, statusCode: statusCode);
    }
  }
}
