import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Modelo de conversacion completa
class ChatConversation extends Equatable {
  final String conversationId;
  final String userId;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.conversationId,
    required this.userId,
    required this.createdAt,
    required this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      conversationId: json['conversationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [conversationId, userId, createdAt, messages];
}

/// Resumen de conversacion (para listados)
class ChatConversationSummary extends Equatable {
  final String conversationId;
  final DateTime createdAt;
  final int messageCount;
  final ChatMessage? lastMessage;

  const ChatConversationSummary({
    required this.conversationId,
    required this.createdAt,
    required this.messageCount,
    this.lastMessage,
  });

  factory ChatConversationSummary.fromJson(Map<String, dynamic> json) {
    final last = json['lastMessage'];
    ChatMessage? parsedLast;

    if (last is Map<String, dynamic>) {
      parsedLast = ChatMessage(
        id: last['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        role: last['role']?.toString().toLowerCase() ?? 'assistant',
        content: last['content']?.toString() ?? '',
        createdAt: DateTime.tryParse(last['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    }

    return ChatConversationSummary(
      conversationId: json['conversationId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      messageCount: int.tryParse(json['messageCount']?.toString() ?? '') ?? 0,
      lastMessage: parsedLast,
    );
  }

  @override
  List<Object?> get props => [conversationId, createdAt, messageCount, lastMessage];
}
