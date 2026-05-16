import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/models/conversation.dart';

class HistoryStorage {
  HistoryStorage() : _box = Hive.box<String>(_boxName);

  static const String _boxName = 'chat_history';
  final Box<String> _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  Future<void> saveConversation(final Conversation conversation) async {
    await _box.put(conversation.id, jsonEncode(conversation.toJson()));
  }

  Future<Conversation?> getConversation(final String id) async {
    final String? data = _box.get(id);
    if (data == null) return null;
    return Conversation.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<List<Conversation>> getAllConversations() async {
    final List<Conversation> conversations = _box.values
        .map(
          (final String data) =>
              Conversation.fromJson(jsonDecode(data) as Map<String, dynamic>),
        )
        .toList();

    conversations.sort((final Conversation a, final Conversation b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return conversations;
  }

  Future<void> deleteConversation(final String id) async {
    await _box.delete(id);
  }

  Future<void> renameConversation(
    final String id,
    final String newTitle,
  ) async {
    final Conversation? conv = await getConversation(id);
    if (conv != null) {
      await saveConversation(conv.copyWith(title: newTitle));
    }
  }

  Future<void> pinConversation(
    final String id, {
    required final bool pinned,
  }) async {
    final Conversation? conv = await getConversation(id);
    if (conv != null) {
      await saveConversation(conv.copyWith(isPinned: pinned));
    }
  }

  Future<void> archiveConversation(
    final String id, {
    required final bool archived,
  }) async {
    final Conversation? conv = await getConversation(id);
    if (conv != null) {
      await saveConversation(conv.copyWith(isArchived: archived));
    }
  }

  Future<List<ChatMessage>> loadMessages(final String conversationId) async {
    final Conversation? conversation = await getConversation(conversationId);
    return conversation?.messages ?? <ChatMessage>[];
  }

  Future<void> upsertConversation(final Conversation conversation) async {
    final Conversation? existing = await getConversation(conversation.id);
    if (existing != null) {
      final Conversation updated = existing.copyWith(
        title: conversation.title,
        lastMessage: conversation.lastMessage,
        updatedAt: conversation.updatedAt,
      );
      await saveConversation(updated);
    } else {
      await saveConversation(conversation);
    }
  }

  Future<void> saveMessages(
    final String conversationId,
    final List<ChatMessage> messages,
  ) async {
    final Conversation? existing = await getConversation(conversationId);
    if (existing != null) {
      final Conversation updated = existing.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
        lastMessage: messages.isNotEmpty
            ? messages.last.text
            : existing.lastMessage,
      );
      await saveConversation(updated);
    } else {
      final Conversation newConv = Conversation(
        id: conversationId,
        title: messages.isNotEmpty ? messages.first.text : 'New Conversation',
        lastMessage: messages.isNotEmpty ? messages.last.text : '',
        updatedAt: DateTime.now(),
        messages: messages,
      );
      await saveConversation(newConv);
    }
  }
}