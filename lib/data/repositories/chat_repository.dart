import 'dart:async';
import 'package:dio/dio.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/services/llm_service.dart';

abstract class ChatRepository {
  Stream<String> streamChat(
    final String prompt,
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  );
}

class ChatRepositoryImpl implements ChatRepository {
  final LlmService _llmService;

  ChatRepositoryImpl(this._llmService);

  @override
  Stream<String> streamChat(
    final String prompt,
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  ) {
    return _llmService.streamCompletion(history, cancelToken);
  }
}
