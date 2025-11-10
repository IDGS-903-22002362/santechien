import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
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
    bool requiresAuth = true,
  }) async {
    try {
      print('🔷 POST Request:');
      print('   Endpoint: $endpoint');
      print('   requiresAuth: $requiresAuth');

      final headers = await _getHeaders(requiresAuth);

      print('   Headers: $headers');
      if (headers.containsKey('Authorization')) {
        final authHeader = headers['Authorization']!;
        print(
          '   ✅ Authorization header present: ${authHeader.substring(0, 20)}...',
        );
      } else {
        print('   ❌ Authorization header MISSING!');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      print('🌐 Enviando petición POST a: $uri');
      print('   Headers finales que se enviarán:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   $key: ${value.substring(0, 30)}...');
        } else {
          print('   $key: $value');
        }
      });

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      print('📨 Petición POST enviada. Status code: ${response.statusCode}');

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

  /// Realizar petición PATCH
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .patch(
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

  /// Obtener headers de la petición
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    print('\n🔍 === _getHeaders LLAMADO ===');
    print('   requiresAuth: $requiresAuth');

    if (!requiresAuth) {
      print('🔓 API Request sin autenticación');
      print('   Retornando headers básicos (sin Authorization)');
      return ApiConfig.headers;
    }

    print('🔐 API Request CON autenticación');
    print('   Intentando obtener token de storage...');

    final token = await _storageService.getAccessToken();
    print(
      '🔑 Token recuperado: ${token != null ? '${token.substring(0, 20)}...' : '⚠️⚠️⚠️ NULL ⚠️⚠️⚠️'}',
    );

    if (token == null) {
      print('❌❌❌ ERROR CRÍTICO: No hay token de acceso en storage ❌❌❌');
      print('   Usuario NO está autenticado o sesión perdida');
      throw Exception('No hay token de acceso - Usuario no autenticado');
    }

    print('✅ Token encontrado, validando...');

    // Verificar si el token está expirado
    try {
      final isExpired = JwtDecoder.isExpired(token);
      print('⏰ Token expirado: $isExpired');

      if (isExpired) {
        print('⚠️ WARNING: El token JWT está EXPIRADO');
        final expirationDate = JwtDecoder.getExpirationDate(token);
        print('   Fecha de expiración: $expirationDate');
        print('   Fecha actual: ${DateTime.now()}');
      } else {
        final remainingTime = JwtDecoder.getRemainingTime(token);
        print(
          '✅ Token válido. Tiempo restante: ${remainingTime.inMinutes} minutos',
        );
      }

      // Decodificar y mostrar claims
      final decodedToken = JwtDecoder.decode(token);
      print('📋 Claims del token:');
      decodedToken.forEach((key, value) {
        print('   $key: $value');
      });
    } catch (e) {
      print('⚠️ Error al decodificar token: $e');
    }

    final headers = ApiConfig.authHeaders(token);
    print('📤 Creando headers con Authorization...');
    print('   Content-Type: ${headers['Content-Type']}');
    print('   Accept: ${headers['Accept']}');

    if (headers.containsKey('Authorization')) {
      print(
        '   ✅✅✅ Authorization: ${headers['Authorization']?.substring(0, 30)}...',
      );
    } else {
      print('   ❌❌❌ Authorization: NO PRESENTE EN HEADERS ❌❌❌');
    }

    print('🔍 === _getHeaders COMPLETADO ===\n');
    return headers;
  }

  /// Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    print('📥 Respuesta HTTP:');
    print('   Status: ${response.statusCode}');
    print('   Body length: ${response.body.length} chars');

    try {
      // Si la respuesta está vacía, retornar error
      if (response.body.isEmpty) {
        print('   ⚠️ Body vacío');
        return ApiResponse<T>(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode == 204
              ? 'Operación exitosa'
              : 'Respuesta vacía',
        );
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      print('   JSON parseado correctamente ✅');
      print('   Estructura: ${jsonData.keys.join(', ')}');
      print('   Body completo: $jsonData');

      // Log específico para respuestas de autenticación
      if (jsonData.containsKey('data')) {
        final data = jsonData['data'];
        print('   Tipo de data: ${data.runtimeType}');
        if (data is Map) {
          print('   data.keys: ${data.keys.join(', ')}');
          if (data.containsKey('accessToken')) {
            print('   ✅ accessToken presente en data');
          }
          if (data.containsKey('refreshToken')) {
            print('   ✅ refreshToken presente en data');
          }
        }
      }

      // Manejar errores HTTP (400+)
      if (response.statusCode >= 400) {
        print('   ❌ Error HTTP ${response.statusCode}');
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

      // Respuesta exitosa (200, 201, etc.)
      print('   ✅ Procesando respuesta exitosa (${response.statusCode})');

      try {
        final apiResponse = ApiResponse<T>.fromJson(jsonData, fromJson);
        print('   ✅ ApiResponse creado exitosamente');
        print('   success: ${apiResponse.success}');
        print('   message: ${apiResponse.message}');
        print('   data presente: ${apiResponse.data != null}');
        return apiResponse;
      } catch (parseError) {
        print('   ❌ Error al crear ApiResponse: $parseError');
        print('   Intentando parseo manual...');

        // Intentar parseo manual como fallback
        return ApiResponse<T>(
          success: jsonData['success'] as bool? ?? true,
          message: jsonData['message'] as String? ?? 'Operación exitosa',
          data: jsonData['data'] != null && fromJson != null
              ? fromJson(jsonData['data'])
              : null,
          errors:
              (jsonData['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );
      }
    } catch (e, stackTrace) {
      print('   ❌ Error al parsear JSON: $e');
      print('   Stack trace: $stackTrace');
      print('   Body completo: ${response.body}');
      return ApiResponse<T>(
        success: false,
        message: 'Error al procesar la respuesta: ${e.toString()}',
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
