import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/repositories/chat_repository.dart';

class MockApiException implements Exception {
  const MockApiException({required this.code, required this.message});

  final int code;
  final String message;

  @override
  String toString() => 'MockApiException($code): $message';
}

class MockChatRepository implements ChatRepository {
  static const String _fullMarkdownResponse =
      "Here's a quick **markdown showcase** for you:\n\n"
      '## Features\n\n'
      '- **Bold text** and *italic text*\n'
      '- Inline `code` and code blocks\n'
      '- Tables and blockquotes\n\n'
      '### Code Example\n\n'
      '```dart\n'
      'void main() {\n'
      "  final greeting = 'Hello, Manus!';\n"
      '  print(greeting);\n'
      '}\n'
      '```\n\n'
      '### Comparison Table\n\n'
      '| Feature | Manus | Others |\n'
      '|---------|-------|--------|\n'
      '| Streaming | ✅ | ⚠️ |\n'
      '| Markdown | ✅ | ❌ |\n'
      '| Speed | Fast | Slow |\n\n'
      '> This is a blockquote with some **important** information.\n\n'
      'Here is a longer paragraph to test bubble growth and scroll behavior '
      'during streaming. The text should appear token by token smoothly '
      'without any jank or layout shifts.';

  static const String _codeResponse =
      'Let me think through this step by step...\n\n'
      '1. First, I\'ll analyze the problem\n'
      '2. Then consider the edge cases\n'
      '3. Finally provide a solution\n\n'
      '```python\n'
      'def fibonacci(n: int) -> list[int]:\n'
      '    if n <= 0:\n'
      '        return []\n'
      '    sequence = [0, 1]\n'
      '    while len(sequence) < n:\n'
      '        sequence.append(sequence[-1] + sequence[-2])\n'
      '    return sequence[:n]\n\n'
      'result = fibonacci(10)\n'
      'print(result)  # [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]\n'
      '```\n\n'
      'The time complexity is **O(n)** and space complexity is **O(n)** as well.';

  static const String _shortResponse =
      "Sure! Here's a simple explanation:\n\n"
      '> "The best code is no code at all." — Jeff Atwood\n\n'
      'Some key points:\n'
      '- Keep it **simple**\n'
      '- Keep it *readable*\n'
      '- Keep it maintainable\n\n'
      "That's all there is to it!";

  static const String _tableResponse =
      "Here's a detailed comparison table:\n\n"
      '| Model | Speed | Quality | Cost |\n'
      '|-------|-------|---------|------|\n'
      '| Gemini 2.5 Flash | ⚡ Fast | ⭐⭐⭐⭐ | Free |\n'
      '| GPT-4o | 🐢 Slow | ⭐⭐⭐⭐⭐ | Paid |\n'
      '| Claude Sonnet | 🚀 Fast | ⭐⭐⭐⭐⭐ | Paid |\n'
      '| Llama 3.3 | ⚡ Fast | ⭐⭐⭐⭐ | Free |\n\n'
      '**Recommendation:** For a free-tier project, Gemini 2.5 Flash is the '
      'best balance of speed and quality.\n\n'
      '> Note: Speed and quality ratings are approximate and may vary based '
      'on use case.';

  static const List<String> _thinkingTokens = <String>[
    '__THINKING__Analyzing your request...',
    '__THINKING__Searching knowledge base...',
    '__THINKING__Formulating response...',
  ];

  @override
  Stream<String> streamChat(
    final String prompt,
    final List<ChatMessage> history,
    final CancelToken cancelToken,
  ) {
    final StreamController<String> controller =
        StreamController<String>.broadcast();

    _run(prompt, cancelToken, controller);

    return controller.stream;
  }

  Future<void> _run(
    final String prompt,
    final CancelToken cancelToken,
    final StreamController<String> controller,
  ) async {
    try {
      final bool failed = await _checkFailureCases(prompt, controller);
      if (failed) return;

      await _maybeEmitThinking(prompt, cancelToken, controller);
      if (cancelToken.isCancelled) {
        AppLogger.info('MockChatRepository: cancelled before streaming');
        await controller.close();
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (cancelToken.isCancelled) {
        AppLogger.info('MockChatRepository: cancelled after latency delay');
        await controller.close();
        return;
      }

      final String response = _selectResponse(prompt);
      await _streamTokens(response, cancelToken, controller);
    } catch (e, st) {
      AppLogger.error('MockChatRepository: unexpected error', e, st);
      controller.addError(e, st);
    } finally {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  Future<bool> _checkFailureCases(
    final String prompt,
    final StreamController<String> controller,
  ) async {
    final String lower = prompt.toLowerCase();
    final ({int delay, MockApiException error})? match = _matchFailure(lower);

    if (match == null) return false;

    await Future<void>.delayed(Duration(milliseconds: match.delay));
    AppLogger.error('MockChatRepository: emitting error ${match.error}');
    controller.addError(match.error);
    await controller.close();
    return true;
  }

  ({int delay, MockApiException error})? _matchFailure(final String lower) {
    if (lower.contains('rate limit')) {
      return (
        delay: 800,
        error: const MockApiException(
          code: 429,
          message: 'Rate limit exceeded. Please try again in a few seconds.',
        ),
      );
    }
    if (lower.contains('network') || lower.contains('offline')) {
      return (
        delay: 400,
        error: const MockApiException(
          code: 0,
          message: 'Network error. Check your connection and retry.',
        ),
      );
    }
    if (lower.contains('server error') || lower.contains('500')) {
      return (
        delay: 600,
        error: const MockApiException(
          code: 500,
          message: 'Internal server error. Our team has been notified.',
        ),
      );
    }
    if (lower.contains('timeout')) {
      return (
        delay: 3000,
        error: const MockApiException(
          code: 408,
          message: 'Request timed out. Please try again.',
        ),
      );
    }
    if (lower.contains('content policy') || lower.contains('blocked')) {
      return (
        delay: 500,
        error: const MockApiException(
          code: 403,
          message: 'Response blocked due to content policy violation.',
        ),
      );
    }
    return null;
  }

  Future<void> _maybeEmitThinking(
    final String prompt,
    final CancelToken cancelToken,
    final StreamController<String> controller,
  ) async {
    final String lower = prompt.toLowerCase();
    final bool needsThinking = lower.contains('think') ||
        lower.contains('reason') ||
        lower.contains('agent');

    if (!needsThinking) return;

    for (final String token in _thinkingTokens) {
      if (cancelToken.isCancelled) return;
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (cancelToken.isCancelled) return;
      controller.add(token);
      AppLogger.info('MockChatRepository: thinking → $token');
    }
  }

  Future<void> _streamTokens(
    final String response,
    final CancelToken cancelToken,
    final StreamController<String> controller,
  ) async {
    final List<String> chunks = _tokenize(response);

    for (int i = 0; i < chunks.length; i++) {
      if (cancelToken.isCancelled) {
        AppLogger.info(
          'MockChatRepository: stream cancelled at chunk $i/${chunks.length}',
        );
        return;
      }

      final String chunk = chunks[i];
      controller.add(chunk);

      final int delay = _delayFor(chunk);
      await Future<void>.delayed(Duration(milliseconds: delay));
    }
  }

  List<String> _tokenize(final String text) {
    final List<String> chunks = <String>[];
    int i = 0;
    final Random rng = Random();

    while (i < text.length) {
      final int size = 1 + rng.nextInt(4);
      final int end = min(i + size, text.length);
      chunks.add(text.substring(i, end));
      i = end;
    }

    return chunks;
  }

  int _delayFor(final String chunk) {
    final int jitter = DateTime.now().millisecondsSinceEpoch % 20;
    final String last = chunk.isEmpty ? '' : chunk[chunk.length - 1];

    if (last == '.' || last == '!' || last == '?') return 80 + jitter;
    if (last == ',' || last == ':') return 40 + jitter;
    if (last == '\n') return 60 + jitter;
    return 20 + jitter;
  }

  String _selectResponse(final String prompt) {
    final String lower = prompt.toLowerCase();

    if (lower.contains('code') ||
        lower.contains('dart') ||
        lower.contains('flutter') ||
        lower.contains('python')) {
      return _codeResponse;
    }
    if (lower.contains('short') ||
        lower.contains('brief') ||
        lower.contains('quick') ||
        lower.contains('tldr')) {
      return _shortResponse;
    }
    if (lower.contains('table')) {
      return _tableResponse;
    }
    return _fullMarkdownResponse;
  }
}
