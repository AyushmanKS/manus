enum MessageRole { user, assistant }

enum MessageStatus { sending, streamed, stopped, error, interrupted }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    required this.status,
    this.isEdited = false,
  });

  factory ChatMessage.fromJson(final Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.byName(json['status'] as String),
      isEdited: json['isEdited'] as bool? ?? false,
    );
  }

  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isEdited;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'isEdited': isEdited,
    };
  }

  ChatMessage copyWith({
    final String? id,
    final MessageRole? role,
    final String? text,
    final DateTime? timestamp,
    final MessageStatus? status,
    final bool? isEdited,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}