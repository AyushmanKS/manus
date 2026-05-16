import 'package:manus/data/models/chat_message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.messages = const <ChatMessage>[],
    this.isPinned = false,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final bool isPinned;
  final bool isArchived;

  Conversation copyWith({
    final String? id,
    final String? title,
    final String? lastMessage,
    final DateTime? updatedAt,
    final List<ChatMessage>? messages,
    final bool? isPinned,
    final bool? isArchived,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((final ChatMessage m) => m.toJson()).toList(),
      'isPinned': isPinned,
      'isArchived': isArchived,
    };
  }

  factory Conversation.fromJson(final Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['lastMessage'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((final dynamic m) =>
                  ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const <ChatMessage>[],
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}

extension ConversationDateGrouping on Conversation {
  String get groupHeader {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime sevenDaysAgo = today.subtract(const Duration(days: 7));

    final DateTime updateDate =
        DateTime(updatedAt.year, updatedAt.month, updatedAt.day);

    if (updateDate == today) {
      return 'Today';
    } else if (updateDate == yesterday) {
      return 'Yesterday';
    } else if (updateDate.isAfter(sevenDaysAgo)) {
      return 'Previous 7 days';
    } else {
      return 'Older';
    }
  }
}
