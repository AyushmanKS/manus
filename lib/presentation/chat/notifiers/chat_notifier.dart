import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/network/api_client.dart';
import 'package:manus/core/network/connectivity_provider.dart';
import 'package:manus/core/network/connectivity_service.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/local/history_storage_provider.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/data/repositories/chat_repository.dart';
import 'package:manus/data/repositories/mock_chat_repository.dart';
import 'package:manus/data/repositories/offline_chat_repository.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/data/services/impl/google_llm_service.dart';
import 'package:uuid/uuid.dart';

import 'package:manus/presentation/chat/notifiers/chat_status_notifiers.dart';
import 'package:manus/presentation/chat/providers/attachment_provider.dart';

const bool kUseMockChat = true;

final Provider<ChatRepository> _chatRepositoryProvider =
    Provider<ChatRepository>((final Ref ref) {
      if (kUseMockChat) {
        return MockChatRepository();
      } else {
        return ChatRepositoryImpl(GoogleLlmService(ApiClient()));
      }
    });

Future<ChatRepository> _resolveRepository(final Ref ref) async {
  final ConnectivityService connectivity = ref.read(
    connectivityServiceProvider,
  );
  final bool online = await connectivity.isConnected;
  if (!online) {
    AppLogger.warning(
      'ChatNotifier: device is offline, using OfflineChatRepository',
    );
    return const OfflineChatRepository();
  }
  return ref.read(_chatRepositoryProvider);
}

Provider<ChatMessage?> chatMessageByIdProvider(final String id) =>
    Provider<ChatMessage?>((final Ref ref) {
      final List<ChatMessage> messages = ref.watch(chatProvider);
      try {
        return messages.firstWhere((final ChatMessage m) => m.id == id);
      } catch (_) {
        return null;
      }
    });

final NotifierProvider<ChatNotifier, List<ChatMessage>> chatProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

final NotifierProvider<ActiveConvNotifier, String>
activeConversationIdProvider = NotifierProvider<ActiveConvNotifier, String>(
  ActiveConvNotifier.new,
);

class ActiveConvNotifier extends Notifier<String> {
  @override
  String build() => const Uuid().v4();

  void set(final String id) => state = id;
}

class ChatNotifier extends Notifier<List<ChatMessage>> {
  CancelToken? _cancelToken;
  String? _activeAssistantId;

  String get _conversationId => ref.read(activeConversationIdProvider);

  @override
  List<ChatMessage> build() => <ChatMessage>[];

  Future<void> loadConversation(final String conversationId) async {
    AppLogger.info('ChatNotifier: loading conversation $conversationId');
    ref.read(activeConversationIdProvider.notifier).set(conversationId);
    final List<ChatMessage> messages = await ref
        .read(historyStorageProvider)
        .loadMessages(conversationId);
    state = messages;
  }

  void startNewConversation() {
    AppLogger.info('ChatNotifier: starting new conversation');
    ref.read(activeConversationIdProvider.notifier).set(const Uuid().v4());
    state = <ChatMessage>[];
  }

  Future<void> sendMessage(
    final String text, {
    final bool isEdited = false,
  }) async {
    _cancelToken = CancelToken();

    final String userId = const Uuid().v4();
    final String assistantId = const Uuid().v4();
    _activeAssistantId = assistantId;
    final DateTime now = DateTime.now();

    final ChatMessage userMessage = ChatMessage(
      id: userId,
      role: MessageRole.user,
      text: text,
      timestamp: now,
      status: MessageStatus.streamed,
      isEdited: isEdited,
    );

    final ChatMessage placeholder = ChatMessage(
      id: assistantId,
      role: MessageRole.assistant,
      text: '',
      timestamp: now,
      status: MessageStatus.sending,
    );

    state = <ChatMessage>[...state, userMessage, placeholder];
    ref.read(chatIsSubmittingProvider.notifier).setSubmitting(true);

    ref.read(attachmentProvider.notifier).clear();

    final List<ChatMessage> history = state
        .where((final ChatMessage m) => m.id != assistantId)
        .toList();

    final ChatRepository repository = await _resolveRepository(ref);

    try {
      final Stream<String> stream = repository.streamChat(
        text,
        history,
        _cancelToken!,
      );

      bool firstToken = true;

      await for (final String token in stream) {
        if (_activeAssistantId != assistantId) break;

        if (firstToken) {
          firstToken = false;
          ref.read(chatIsSubmittingProvider.notifier).setSubmitting(false);
          ref.read(chatIsStreamingProvider.notifier).setStreaming(true);
        }

        final List<ChatMessage> updated = state.toList();
        final int idx = updated.indexWhere(
          (final ChatMessage m) => m.id == assistantId,
        );
        if (idx == -1) break;

        updated[idx] = updated[idx].copyWith(
          text: updated[idx].text + token,
          status: MessageStatus.sending,
        );
        state = updated;
      }

      final List<ChatMessage> finished = state.toList();
      final int idx = finished.indexWhere(
        (final ChatMessage m) => m.id == assistantId,
      );
      if (idx != -1 && finished[idx].status != MessageStatus.stopped) {
        finished[idx] = finished[idx].copyWith(status: MessageStatus.streamed);
        state = finished;
      }
    } catch (e) {
      AppLogger.error('ChatNotifier.sendMessage error', e);
      final List<ChatMessage> errored = state.toList();
      final int idx = errored.indexWhere(
        (final ChatMessage m) => m.id == assistantId,
      );
      if (idx != -1 && errored[idx].status != MessageStatus.stopped) {
        final String errorMessage = _errorMessage(e);
        errored[idx] = errored[idx].copyWith(
          text: errorMessage,
          status: MessageStatus.error,
        );
        state = errored;
      }
    } finally {
      ref.read(chatIsSubmittingProvider.notifier).setSubmitting(false);
      ref.read(chatIsStreamingProvider.notifier).setStreaming(false);
      _activeAssistantId = null;
      await _persist();
    }
  }

  void stopStream() {
    _cancelToken?.cancel();
    _activeAssistantId = null;

    final List<ChatMessage> updated = state.toList();
    final int idx = updated.lastIndexWhere(
      (final ChatMessage m) => m.role == MessageRole.assistant,
    );
    if (idx != -1) {
      updated[idx] = updated[idx].copyWith(status: MessageStatus.stopped);
      state = updated;
    }

    ref.read(chatIsSubmittingProvider.notifier).setSubmitting(false);
    ref.read(chatIsStreamingProvider.notifier).setStreaming(false);
    unawaited(_persist());
  }

  Future<void> editAndResend(
    final String messageId,
    final String newText,
  ) async {
    final int index = state.indexWhere(
      (final ChatMessage m) => m.id == messageId,
    );
    if (index == -1 || state[index].role != MessageRole.user) {
      AppLogger.warning('Cannot edit message: invalid ID or role');
      return;
    }

    AppLogger.debug('Forking conversation from index $index');
    state = state.sublist(0, index);
    await _persist();
    await sendMessage(newText, isEdited: true);
  }

  Future<void> regenerateLastMessage() async {
    final List<ChatMessage> current = state.toList();
    final int lastAssistantIdx = current.lastIndexWhere(
      (final ChatMessage m) => m.role == MessageRole.assistant,
    );
    if (lastAssistantIdx == -1) return;

    current.removeAt(lastAssistantIdx);
    state = current;

    final int lastUserIdx = state.lastIndexWhere(
      (final ChatMessage m) => m.role == MessageRole.user,
    );
    if (lastUserIdx == -1) return;

    final String prompt = state[lastUserIdx].text;
    await sendMessage(prompt);
  }

  Future<void> retryLastError() async {
    final List<ChatMessage> current = state.toList();
    final int errorIdx = current.lastIndexWhere(
      (final ChatMessage m) => m.status == MessageStatus.error,
    );
    if (errorIdx == -1) return;

    current.removeAt(errorIdx);
    state = current;

    final int lastUserIdx = state.lastIndexWhere(
      (final ChatMessage m) => m.role == MessageRole.user,
    );
    if (lastUserIdx == -1) return;

    final String prompt = state[lastUserIdx].text;
    await sendMessage(prompt);
  }

  String _errorMessage(final Object e) {
    if (e is NoConnectionException) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'The connection timed out. Please check your internet.';
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return 'Invalid API key. Please check your configuration.';
      }
    }
    final String msg = e.toString();
    if (msg.contains('MockApiException')) {
      final int start = msg.indexOf(': ');
      if (start != -1) return msg.substring(start + 2);
    }
    return 'Sorry, something went wrong. Please try again.';
  }

  Future<void> deleteMessage(final String messageId) async {
    state = state.where((final ChatMessage m) => m.id != messageId).toList();
    await _persist();
  }

  Future<void> regenerate(final String messageId) async {
    final int index = state.indexWhere(
      (final ChatMessage m) => m.id == messageId,
    );
    if (index == -1) return;

    state = state.sublist(0, index);
    final int lastUserIdx = state.lastIndexWhere(
      (final ChatMessage m) => m.role == MessageRole.user,
    );
    if (lastUserIdx == -1) return;

    final String prompt = state[lastUserIdx].text;
    await sendMessage(prompt);
  }

  Future<void> _persist() async {
    final String convId = _conversationId;
    await ref.read(historyStorageProvider).saveMessages(convId, state);
    await _upsertConversation(convId);
    unawaited(ref.read(historyProvider.notifier).refresh());
  }

  Future<void> _upsertConversation(final String convId) async {
    if (state.isEmpty) return;
    final ChatMessage first = state.first;
    final ChatMessage last = state.last;
    final String title = first.role == MessageRole.user
        ? _truncate(first.text, 40)
        : 'Conversation';
    final String preview = _truncate(last.text, 60);
    final Conversation conversation = Conversation(
      id: convId,
      title: title,
      lastMessage: preview,
      updatedAt: last.timestamp,
    );
    await ref.read(historyStorageProvider).upsertConversation(conversation);
    AppLogger.debug('ChatNotifier: upserted conversation $convId');
  }

  String _truncate(final String text, final int maxLength) {
    final String clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length <= maxLength
        ? clean
        : '${clean.substring(0, maxLength)}...';
  }
}
