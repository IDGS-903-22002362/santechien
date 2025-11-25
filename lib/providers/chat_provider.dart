import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/chat_reply.dart';
import '../services/chat_service.dart';

/// Provider para manejar estado del chatbot
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = false;
  String? _conversationId;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get conversationId => _conversationId;
  String? get errorMessage => _errorMessage;

  /// Reiniciar la conversacion actual
  void reset({String? conversationId}) {
    _messages.clear();
    _conversationId = conversationId;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cargar historial de mensajes para una conversacion existente
  Future<void> loadConversation({
    required String conversationId,
    required String userId,
  }) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ChatConversation conversation = await _chatService.getConversation(
        conversationId: conversationId,
        userId: userId,
      );

      _conversationId = conversation.conversationId;
      _messages
        ..clear()
        ..addAll(conversation.messages);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Enviar mensaje al chatbot
  Future<ChatReply> sendMessage({
    required String userId,
    required String content,
  }) async {
    if (_isSending) {
      throw Exception('Ya hay un mensaje en envio.');
    }

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw Exception('El mensaje no puede estar vacio.');
    }

    _isSending = true;
    _errorMessage = null;

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final placeholder = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}-typing',
      role: 'assistant',
      content: 'Escribiendo...',
      createdAt: DateTime.now(),
      isPlaceholder: true,
    );

    _messages
      ..add(userMessage)
      ..add(placeholder);
    notifyListeners();

    try {
      final reply = await _chatService.sendMessage(
        userId: userId,
        message: trimmed,
        conversationId: _conversationId,
      );

      if (_conversationId == null && reply.conversationId.isNotEmpty) {
        _conversationId = reply.conversationId;
      }

      _messages.removeWhere((m) => m.id == placeholder.id);
      _messages.add(
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          role: 'assistant',
          content: reply.answer,
          createdAt: DateTime.now(),
        ),
      );

      _errorMessage = null;
      return reply;
    } catch (e) {
      _messages.removeWhere((m) => m.id == placeholder.id);
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
