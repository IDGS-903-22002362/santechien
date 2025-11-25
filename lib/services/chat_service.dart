import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/chat_reply.dart';
import 'storage_service.dart';

/// Servicio para interactuar con el chatbot
class ChatService {
  final StorageService _storage = StorageService();

  /// Enviar un mensaje al chatbot
  Future<ChatReply> sendMessage({
    required String userId,
    required String message,
    String? conversationId,
  }) async {
    final uri = _buildUri('/Chat/ask');
    final headers = await _buildHeaders();
    final body = jsonEncode({
      'userId': userId,
      'message': message,
      'conversationId': conversationId,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ChatReply.fromJson(decoded, fallbackId: conversationId);
        }
        throw Exception('Formato de respuesta no valido.');
      }

      throw Exception(_parseError(response.body, response.statusCode));
    } on SocketException {
      throw Exception('No hay conexion a internet.');
    } on TimeoutException {
      throw Exception('La solicitud de chat tardo demasiado.');
    }
  }

  /// Obtener historial completo de una conversacion
  Future<ChatConversation> getConversation({
    required String conversationId,
    required String userId,
  }) async {
    final uri = _buildUri(
      '/Chat/conversation/$conversationId',
      queryParameters: {'userId': userId},
    );
    final headers = await _buildHeaders();

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ChatConversation.fromJson(decoded);
        }
        throw Exception('Formato de respuesta no valido.');
      }

      throw Exception(_parseError(response.body, response.statusCode));
    } on SocketException {
      throw Exception('No hay conexion a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardo demasiado.');
    }
  }

  /// Obtener listado de conversaciones del usuario
  Future<List<ChatConversationSummary>> getUserConversations({
    required String userId,
  }) async {
    final uri = _buildUri(
      '/Chat/conversations',
      queryParameters: {'userId': userId},
    );
    final headers = await _buildHeaders();

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => ChatConversationSummary.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
        }
        return [];
      }

      throw Exception(_parseError(response.body, response.statusCode));
    } on SocketException {
      throw Exception('No hay conexion a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardo demasiado.');
    }
  }

  /// Construir headers incluyendo token si existe
  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = Map<String, String>.from(ApiConfig.headers);

    if (!requiresAuth) return headers;

    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Crear URI completa a partir del path y query params
  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$base$normalizedPath').replace(
      queryParameters: queryParameters,
    );
  }

  /// Extraer mensaje de error legible
  String _parseError(String body, int statusCode) {
    try {
      final jsonBody = jsonDecode(body);
      if (jsonBody is Map<String, dynamic>) {
        if (jsonBody['error'] != null) {
          return jsonBody['error'].toString();
        }
        if (jsonBody['message'] != null) {
          return jsonBody['message'].toString();
        }
      }
    } catch (_) {}

    return 'Error en la solicitud ($statusCode).';
  }
}
