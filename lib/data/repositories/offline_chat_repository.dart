import 'dart:async';

import 'package:dio/dio.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/repositories/chat_repository.dart';

class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

class OfflineChatRepository implements ChatRepository {
  const OfflineChatRepository();

  @override
  Stream<String> streamChat(
    final String prompt,
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  ) {
    AppLogger.warning(
      'OfflineChatRepository: streamChat called while offline — emitting NoConnectionException',
    );

    final StreamController<String> controller =
        StreamController<String>.broadcast();

    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!controller.isClosed) {
        AppLogger.error(
          'OfflineChatRepository: no connection, closing stream with error',
        );
        controller.addError(const NoConnectionException());
        unawaited(controller.close());
      }
    });

    return controller.stream;
  }
}