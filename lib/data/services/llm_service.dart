import 'package:dio/dio.dart';
import 'package:manus/data/models/chat_message.dart';

abstract class LlmService {
  Stream<String> streamCompletion(
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  );
}