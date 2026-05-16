import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/data/local/history_storage_provider.dart';
import 'package:manus/data/models/conversation.dart';

class HistorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(final String query) => state = query;
  void clear() => state = '';
}

final NotifierProvider<HistorySearchNotifier, String> historySearchProvider =
    NotifierProvider<HistorySearchNotifier, String>(HistorySearchNotifier.new);

class RenamingChatIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(final String? id) => state = id;
}

final NotifierProvider<RenamingChatIdNotifier, String?> renamingChatIdProvider =
    NotifierProvider<RenamingChatIdNotifier, String?>(RenamingChatIdNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  FutureOr<List<Conversation>> build() async {
    return ref.read(historyStorageProvider).getAllConversations();
  }

  Future<void> refresh() async {
    state = const AsyncValue<List<Conversation>>.loading();
    state = await AsyncValue.guard(
      () => ref.read(historyStorageProvider).getAllConversations(),
    );
  }

  Future<void> reload() => refresh();

  Future<void> deleteConversation(final String id) async {
    await ref.read(historyStorageProvider).deleteConversation(id);
    await refresh();
  }

  Future<void> renameChat(final String chatId, final String newName) async {
    await ref.read(historyStorageProvider).renameConversation(chatId, newName);
    await refresh();
  }

  Future<void> archiveChat(final String chatId) async {
    await ref.read(historyStorageProvider).archiveConversation(chatId, archived: true);
    await refresh();
  }

  Future<void> pinConversation(final String id, {required final bool pinned}) async {
    await ref.read(historyStorageProvider).pinConversation(id, pinned: pinned);
    await refresh();
  }

  Future<void> archiveConversation(final String id, {required final bool archived}) async {
    await ref.read(historyStorageProvider).archiveConversation(id, archived: archived);
    await refresh();
  }
}

final AsyncNotifierProvider<HistoryNotifier, List<Conversation>> historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<Conversation>>(HistoryNotifier.new);

final Provider<Map<String, List<Conversation>>> groupedHistoryProvider =
    Provider<Map<String, List<Conversation>>>((final Ref ref) {
  final List<Conversation> list =
      ref.watch(historyProvider).value ?? <Conversation>[];
  final String query = ref.watch(historySearchProvider).toLowerCase();

  final Map<String, List<Conversation>> groups = <String, List<Conversation>>{};

  for (final Conversation conv in list) {
    if (conv.isArchived) continue;

    if (query.isNotEmpty) {
      if (!conv.title.toLowerCase().contains(query) &&
          !conv.lastMessage.toLowerCase().contains(query)) {
        continue;
      }
    }

    final String header = conv.groupHeader;
    groups.putIfAbsent(header, () => <Conversation>[]).add(conv);
  }
  return groups;
});
