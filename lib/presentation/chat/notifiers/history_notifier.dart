import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/data/local/history_storage_provider.dart';
import 'package:manus/data/models/conversation.dart';

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

  Future<void> renameConversation(final String id, final String newTitle) async {
    await ref.read(historyStorageProvider).renameConversation(id, newTitle);
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

  Map<String, List<Conversation>> get grouped {
    final List<Conversation> list = state.value ?? <Conversation>[];
    final Map<String, List<Conversation>> groups = <String, List<Conversation>>{};

    for (final Conversation conv in list) {
      if (conv.isArchived) continue;
      final String header = conv.groupHeader;
      groups.putIfAbsent(header, () => <Conversation>[]).add(conv);
    }
    return groups;
  }
}

final AsyncNotifierProvider<HistoryNotifier, List<Conversation>> historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<Conversation>>(HistoryNotifier.new);

final Provider<String> historySearchQueryProvider = Provider<String>((final Ref ref) => '');
