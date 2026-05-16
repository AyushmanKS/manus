import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/models/conversation.dart';

abstract class HistoryStorageService {
  Future<void> upsertConversation(final Conversation conversation);

  Future<Conversation?> getConversation(final String id);

  Future<List<Conversation>> getAllConversations();

  Future<void> deleteConversation(final String id);

  Future<void> renameConversation(final String id, final String newTitle);

  Future<void> pinConversation(final String id, {required final bool pinned});

  Future<void> archiveConversation(
    final String id, {
    required final bool archived,
  });

  Future<void> saveMessages(
    final String conversationId,
    final List<ChatMessage> messages,
  );

  Future<List<ChatMessage>> loadMessages(final String conversationId);
}

class HiveHistoryStorageService implements HistoryStorageService {
  static const String _historyBox = 'chat_history';
  static const String _messagesBox = 'conversations';

  Box<String> get _history => Hive.box<String>(_historyBox);

  Box<String> get _messages => Hive.box<String>(_messagesBox);

  @override
  Future<void> upsertConversation(final Conversation conversation) async {
    AppLogger.debug(
      'HistoryStorageService: upsert conversation ${conversation.id}',
    );
    await _history.put(conversation.id, jsonEncode(conversation.toJson()));
  }

  @override
  Future<Conversation?> getConversation(final String id) async {
    final String? raw = _history.get(id);
    if (raw == null) {
      AppLogger.debug('HistoryStorageService: conversation $id not found');
      return null;
    }
    return Conversation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<Conversation>> getAllConversations() async {
    final List<Conversation> result = _history.values
        .map(
          (final String raw) =>
              Conversation.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    AppLogger.info(
      'HistoryStorageService: loaded ${result.length} conversations',
    );
    return result;
  }

  @override
  Future<void> deleteConversation(final String id) async {
    AppLogger.info('HistoryStorageService: deleting conversation $id');
    await _history.delete(id);
    await _messages.delete(id);
  }

  @override
  Future<void> renameConversation(
    final String id,
    final String newTitle,
  ) async {
    final Conversation? conv = await getConversation(id);
    if (conv == null) {
      AppLogger.warning(
        'HistoryStorageService: rename failed — conversation $id not found',
      );
      return;
    }
    AppLogger.debug('HistoryStorageService: renaming $id to "$newTitle"');
    await upsertConversation(conv.copyWith(title: newTitle));
  }

  @override
  Future<void> pinConversation(
    final String id, {
    required final bool pinned,
  }) async {
    final Conversation? conv = await getConversation(id);
    if (conv == null) return;
    AppLogger.debug('HistoryStorageService: pin $id → $pinned');
    await upsertConversation(conv.copyWith(isPinned: pinned));
  }

  @override
  Future<void> archiveConversation(
    final String id, {
    required final bool archived,
  }) async {
    final Conversation? conv = await getConversation(id);
    if (conv == null) return;
    AppLogger.debug('HistoryStorageService: archive $id → $archived');
    await upsertConversation(conv.copyWith(isArchived: archived));
  }

  @override
  Future<void> saveMessages(
    final String conversationId,
    final List<ChatMessage> messages,
  ) async {
    final String encoded = jsonEncode(
      messages.map((final ChatMessage m) => m.toJson()).toList(),
    );
    await _messages.put(conversationId, encoded);
    AppLogger.debug(
      'HistoryStorageService: saved ${messages.length} messages for $conversationId',
    );
  }

  @override
  Future<List<ChatMessage>> loadMessages(final String conversationId) async {
    final String? raw = _messages.get(conversationId);
    if (raw == null) {
      AppLogger.debug(
        'HistoryStorageService: no messages found for $conversationId',
      );
      return <ChatMessage>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final List<ChatMessage> messages = decoded
        .map(
          (final dynamic e) => ChatMessage.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    AppLogger.info(
      'HistoryStorageService: loaded ${messages.length} messages for $conversationId',
    );
    return messages;
  }
}
