import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manus/data/models/chat_message.dart';

abstract class ChatRepository {
  Stream<String> streamChat(
    String prompt,
    List<ChatMessage> history,
    CancelToken cancelToken,
  );
}

class GeminiRepository implements ChatRepository {
  GeminiRepository(this._dio);

  final Dio _dio;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent';

  List<Map<String, dynamic>> _buildContents(
    final String prompt,
    final List<ChatMessage> history,
  ) {
    final List<Map<String, dynamic>> contents = history
        .map(
          (final ChatMessage m) => <String, dynamic>{
            'role': m.role == MessageRole.user ? 'user' : 'model',
            'parts': <Map<String, dynamic>>[
              <String, dynamic>{'text': m.text},
            ],
          },
        )
        .toList();

    contents.add(<String, dynamic>{
      'role': 'user',
      'parts': <Map<String, dynamic>>[
        <String, dynamic>{'text': prompt},
      ],
    });

    return contents;
  }

  String? _extractToken(final String jsonStr) {
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final Object? candidatesRaw = decoded['candidates'];
      if (candidatesRaw is! List<dynamic> || candidatesRaw.isEmpty) {
        return null;
      }
      final Object? contentRaw = candidatesRaw[0]['content'];
      if (contentRaw is! Map<String, dynamic>) return null;
      final Object? partsRaw = contentRaw['parts'];
      if (partsRaw is! List<dynamic> || partsRaw.isEmpty) return null;
      final Object? text = (partsRaw[0] as Map<String, dynamic>)['text'];
      return text is String ? text : null;
    } catch (_) {
      return null;
    }
  }

  void _processLines(
    final String raw,
    final StringBuffer lineBuffer,
    final StreamController<String> controller,
  ) {
    lineBuffer.write(raw);
    final List<String> lines = lineBuffer.toString().split('\n');

    for (int i = 0; i < lines.length - 1; i++) {
      final String line = lines[i].trim();
      if (!line.startsWith('data: ')) continue;
      final String jsonStr = line.substring(6).trim();
      if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;
      final String? token = _extractToken(jsonStr);
      if (token != null && token.isNotEmpty) {
        controller.add(token);
      }
    }

    lineBuffer
      ..clear()
      ..write(lines.last);
  }

  @override
  Stream<String> streamChat(
    final String prompt,
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  ) {
    final StreamController<String> controller =
        StreamController<String>();

    Future<void> fetch() async {
      final StringBuffer lineBuffer = StringBuffer();

      try {
        final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        final Response<ResponseBody> response =
            await _dio.post<ResponseBody>(
          '$_baseUrl?alt=sse&key=$apiKey',
          data: <String, dynamic>{
            'contents': _buildContents(prompt, history),
          },
          options: Options(responseType: ResponseType.stream),
          cancelToken: cancelToken,
        );

        await for (final List<int> chunk in response.data!.stream) {
          if (cancelToken.isCancelled) break;
          _processLines(
            utf8.decode(chunk, allowMalformed: true),
            lineBuffer,
            controller,
          );
        }

        await controller.close();
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          await controller.close();
        } else {
          controller.addError(e);
          await controller.close();
        }
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    }

    unawaited(fetch());
    return controller.stream;
  }
}
