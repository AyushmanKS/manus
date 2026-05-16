import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:manus/core/network/api_client.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/services/llm_service.dart';

class GoogleLlmService implements LlmService {
  final ApiClient _apiClient;

  GoogleLlmService(this._apiClient);

  static const String _model = 'gemini-1.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/$_model:streamGenerateContent';

  @override
  Stream<String> streamCompletion(
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  ) {
    final StreamController<String> controller = StreamController<String>();

    Future<void> fetch() async {
      try {
        final String? apiKey = dotenv.env['GEMINI_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('GEMINI_API_KEY is missing');
        }

        final Response<ResponseBody> response = await _apiClient.postStream(
          '$_baseUrl?alt=sse&key=$apiKey',
          data: <String, dynamic>{
            'contents': history
                .where((final ChatMessage m) => m.text.isNotEmpty)
                .map(
                  (final ChatMessage m) => <String, dynamic>{
                    'role': m.role == MessageRole.user ? 'user' : 'model',
                    'parts': <Map<String, dynamic>>[
                      <String, dynamic>{'text': m.text},
                    ],
                  },
                )
                .toList(),
            'generationConfig': <String, dynamic>{
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 2048,
            },
          },
          headers: <String, String>{'Content-Type': 'application/json'},
          cancelToken: cancelToken,
        );

        final StringBuffer lineBuffer = StringBuffer();

        await for (final List<int> chunk in response.data!.stream) {
          if (cancelToken.isCancelled) break;

          final String decoded = utf8.decode(chunk, allowMalformed: true);
          lineBuffer.write(decoded);

          final String currentBuffer = lineBuffer.toString();
          final List<String> lines = currentBuffer.split(RegExp(r'\r?\n'));

          for (int i = 0; i < lines.length - 1; i++) {
            final String line = lines[i].trim();
            if (line.isEmpty || !line.startsWith('data: ')) continue;

            final String jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]') {
              await controller.close();
              return;
            }

            final String? token = _extractToken(jsonStr);
            if (token != null && token.isNotEmpty) {
              controller.add(token);
            }
          }

          lineBuffer.clear();
          lineBuffer.write(lines.last);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      } finally {
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }

    unawaited(fetch());
    return controller.stream;
  }

  String? _extractToken(final String jsonStr) {
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final List<dynamic>? candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final Map<String, dynamic>? firstCandidate =
          candidates[0] as Map<String, dynamic>?;
      final Map<String, dynamic>? content =
          firstCandidate?['content'] as Map<String, dynamic>?;
      final List<dynamic>? parts = content?['parts'] as List<dynamic>?;

      if (parts == null || parts.isEmpty) return null;

      final Map<String, dynamic>? firstPart = parts[0] as Map<String, dynamic>?;
      return firstPart?['text'] as String?;
    } catch (e) {
      AppLogger.error('Extraction failed: $e');
      return null;
    }
  }
}