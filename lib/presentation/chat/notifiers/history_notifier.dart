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
    NotifierProvider<RenamingChatIdNotifier, String?>(
      RenamingChatIdNotifier.new,
    );

class ArchivedViewVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final NotifierProvider<ArchivedViewVisibleNotifier, bool>
isArchivedViewVisibleProvider =
    NotifierProvider<ArchivedViewVisibleNotifier, bool>(
      ArchivedViewVisibleNotifier.new,
    );

class HistoryState {
  const HistoryState({required this.activeChats, required this.archivedChats});

  final List<Conversation> activeChats;
  final List<Conversation> archivedChats;
}

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  @override
  FutureOr<HistoryState> build() async {
    return _loadHistory();
  }

  Future<HistoryState> _loadHistory() async {
    final List<Conversation> all = await ref
        .read(historyStorageProvider)
        .getAllConversations();
    return HistoryState(
      activeChats: all.where((final Conversation c) => !c.isArchived).toList(),
      archivedChats: all.where((final Conversation c) => c.isArchived).toList(),
    );
  }

  Future<void> refresh() async {
    // We don't set state to loading() synchronously to avoid
    // "Tried to modify a provider while the widget tree was building"
    // and to prevent the UI from flashing a loader if we already have data.
    final AsyncValue<HistoryState> newState = await AsyncValue.guard(
      () => _loadHistory(),
    );
    if (ref.mounted) {
      state = newState;
    }
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
    await ref
        .read(historyStorageProvider)
        .archiveConversation(chatId, archived: true);
    await refresh();
  }

  Future<void> unarchiveChat(final String chatId) async {
    await ref
        .read(historyStorageProvider)
        .archiveConversation(chatId, archived: false);
    await refresh();
  }

  Future<void> pinConversation(
    final String id, {
    required final bool pinned,
  }) async {
    await ref.read(historyStorageProvider).pinConversation(id, pinned: pinned);
    await refresh();
  }

  Future<void> archiveConversation(
    final String id, {
    required final bool archived,
  }) async {
    await ref
        .read(historyStorageProvider)
        .archiveConversation(id, archived: archived);
    await refresh();
  }
}

final AsyncNotifierProvider<HistoryNotifier, HistoryState> historyProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

final Provider<Map<String, List<Conversation>>> groupedHistoryProvider =
    Provider<Map<String, List<Conversation>>>((final Ref ref) {
      final AsyncValue<HistoryState> history = ref.watch(historyProvider);
      final List<Conversation> list =
          history.value?.activeChats ?? <Conversation>[];
      return _groupList(ref, list);
    });

final Provider<Map<String, List<Conversation>>> groupedArchivedHistoryProvider =
    Provider<Map<String, List<Conversation>>>((final Ref ref) {
      final AsyncValue<HistoryState> history = ref.watch(historyProvider);
      final List<Conversation> list =
          history.value?.archivedChats ?? <Conversation>[];
      return _groupList(ref, list);
    });

Map<String, List<Conversation>> _groupList(
  final Ref ref,
  final List<Conversation> list,
) {
  final String query = ref.watch(historySearchProvider).toLowerCase();
  final Map<String, List<Conversation>> groups = <String, List<Conversation>>{};

  for (final Conversation conv in list) {
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
}
