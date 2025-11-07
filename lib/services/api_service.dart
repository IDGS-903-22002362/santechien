import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

/// Servicio base para comunicación con la API
class ApiService {
  final _storageService = StorageService();

  /// Realizar petición GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgNetworkError,
        errors: const ['No hay conexión a internet'],
      );
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'La solicitud tardó demasiado tiempo',
        errors: const ['Tiempo de espera agotado'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgUnknownError,
        errors: [e.toString()],
      );
    }
  }

  /// Realizar petición POST
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgNetworkError,
        errors: const ['No hay conexión a internet'],
      );
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'La solicitud tardó demasiado tiempo',
        errors: const ['Tiempo de espera agotado'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgUnknownError,
        errors: [e.toString()],
      );
    }
  }

  /// Realizar petición PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgNetworkError,
        errors: const ['No hay conexión a internet'],
      );
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'La solicitud tardó demasiado tiempo',
        errors: const ['Tiempo de espera agotado'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgUnknownError,
        errors: [e.toString()],
      );
    }
  }

  /// Realizar petición DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgNetworkError,
        errors: const ['No hay conexión a internet'],
      );
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'La solicitud tardó demasiado tiempo',
        errors: const ['Tiempo de espera agotado'],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: AppConstants.msgUnknownError,
        errors: [e.toString()],
      );
    }
  }

  /// Obtener headers de la petición
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (!requiresAuth) {
      return ApiConfig.headers;
    }

    final token = await _storageService.getAccessToken();
    if (token == null) {
      throw Exception('No hay token de acceso');
    }

    return ApiConfig.authHeaders(token);
  }

  /// Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      // Manejar errores HTTP
      if (response.statusCode >= 400) {
        return ApiResponse<T>(
          success: false,
          message:
              jsonData['message'] as String? ??
              _getErrorMessage(response.statusCode),
          errors:
              (jsonData['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );
      }

      // Respuesta exitosa
      return ApiResponse<T>.fromJson(jsonData, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Error al procesar la respuesta',
        errors: [e.toString()],
      );
    }
  }

  /// Obtener mensaje de error según código HTTP
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta';
      case 401:
        return AppConstants.msgSessionExpired;
      case 403:
        return AppConstants.msgUnauthorized;
      case 404:
        return 'Recurso no encontrado';
      case 500:
        return 'Error interno del servidor';
      case 503:
        return 'Servicio no disponible';
      default:
        return 'Error en la solicitud ($statusCode)';
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Timeout']);

  @override
  String toString() => message;
}
