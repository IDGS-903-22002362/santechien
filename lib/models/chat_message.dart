import 'package:equatable/equatable.dart';

/// Modelo de mensaje de chat
class ChatMessage extends Equatable {
  final String id;
  final String role; // user | assistant
  final String content;
  final DateTime createdAt;
  final bool isPlaceholder;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isPlaceholder = false,
  });

  bool get isUser => role.toLowerCase() == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      role: json['role']?.toString().toLowerCase() ?? 'assistant',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? isPlaceholder,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isPlaceholder': isPlaceholder,
    };
  }

  @override
  List<Object?> get props => [id, role, content, createdAt, isPlaceholder];
}
