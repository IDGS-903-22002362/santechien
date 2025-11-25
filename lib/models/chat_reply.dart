import 'package:equatable/equatable.dart';

/// Respuesta de la API al enviar un mensaje
class ChatReply extends Equatable {
  final String conversationId;
  final String answer;

  const ChatReply({
    required this.conversationId,
    required this.answer,
  });

  factory ChatReply.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return ChatReply(
      conversationId: json['conversationId']?.toString() ??
          fallbackId ??
          '',
      answer: json['answer']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [conversationId, answer];
}
