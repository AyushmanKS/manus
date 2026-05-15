import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:manus/core/network/api_client.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/repositories/chat_repository.dart';
import 'package:manus/data/repositories/mock_chat_repository.dart';
import 'package:manus/data/services/impl/google_llm_service.dart';
import 'package:uuid/uuid.dart';

const bool kUseMockChat = true;

final Provider<ChatRepository> _chatRepositoryProvider =
    Provider<ChatRepository>((final Ref ref) {
      if (kUseMockChat) {
        return MockChatRepository();
      } else {
        return ChatRepositoryImpl(GoogleLlmService(ApiClient()));
      }
    });

final NotifierProvider<StreamingNotifier, bool> chatIsStreamingProvider =
    NotifierProvider<StreamingNotifier, bool>(StreamingNotifier.new);

class StreamingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setStreaming(final bool value) => state = value;
}

final NotifierProvider<ChatNotifier, List<ChatMessage>> chatProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

class ChatNotifier extends Notifier<List<ChatMessage>> {
  CancelToken? _cancelToken;
  String? _activeAssistantId;

  @override
  List<ChatMessage> build() {
    return <ChatMessage>[];
  }

  Future<void> sendMessage(final String text) async {
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
    );

    final ChatMessage placeholder = ChatMessage(
      id: assistantId,
      role: MessageRole.assistant,
      text: '',
      timestamp: now,
      status: MessageStatus.sending,
    );

    state = <ChatMessage>[...state, userMessage, placeholder];
    ref.read(chatIsStreamingProvider.notifier).setStreaming(true);

    final List<ChatMessage> history = state
        .where((final ChatMessage m) => m.id != assistantId)
        .toList();

    final ChatRepository repository = ref.read(_chatRepositoryProvider);

    try {
      final Stream<String> stream = repository.streamChat(
        text,
        history,
        _cancelToken!,
      );

      await for (final String token in stream) {
        if (_activeAssistantId != assistantId) break;

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
      final List<ChatMessage> errored = state.toList();
      final int idx = errored.indexWhere(
        (final ChatMessage m) => m.id == assistantId,
      );
      if (idx != -1 && errored[idx].status != MessageStatus.stopped) {
        String errorMessage = 'Sorry, something went wrong. Please try again.';
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage =
                'The connection timed out. Please check your internet.';
          } else if (e.response?.statusCode == 401 ||
              e.response?.statusCode == 403) {
            errorMessage = 'Invalid API key. Please check your configuration.';
          }
        }

        errored[idx] = errored[idx].copyWith(
          text: errorMessage,
          status: MessageStatus.error,
        );
        state = errored;
      }
    } finally {
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

    ref.read(chatIsStreamingProvider.notifier).setStreaming(false);
    unawaited(_persist());
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

  Future<void> _persist() async {
    final Box<String> box = Hive.box<String>('conversations');
    final String encoded = jsonEncode(
      state.map((final ChatMessage m) => m.toJson()).toList(),
    );
    await box.put('messages', encoded);
  }
}
