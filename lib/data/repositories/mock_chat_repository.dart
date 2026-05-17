import 'dart:async';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:dio/dio.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/data/local/suggestion_data.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/data/models/suggestion.dart';
import 'package:manus/data/repositories/chat_repository.dart';

class MockApiException implements Exception {
  const MockApiException({required this.code, required this.message});

  final int code;
  final String message;

  @override
  String toString() => 'MockApiException($code): $message';
}

class MockChatRepository implements ChatRepository {
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
    return null;
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
      if (chunk.isEmpty) continue;
      controller.add(chunk);

      final int delay = _delayFor(chunk);
      await Future<void>.delayed(Duration(milliseconds: delay));
    }
  }

  List<String> _tokenize(final String text) {
    final List<String> graphemes = text.characters.toList();
    final List<String> chunks = <String>[];
    int i = 0;
    final Random rng = Random();

    while (i < graphemes.length) {
      final int size = 1 + rng.nextInt(6);
      final int end = min(i + size, graphemes.length);
      chunks.add(graphemes.sublist(i, end).join());
      i = end;
    }

    return chunks;
  }

  int _delayFor(final String chunk) {
    final int jitter = DateTime.now().millisecondsSinceEpoch % 15;
    final String last = chunk.isEmpty ? '' : chunk[chunk.length - 1];

    if (last == '.' || last == '!' || last == '?') return 60 + jitter;
    if (last == '\n') return 40 + jitter;
    return 15 + jitter;
  }

  String _selectResponse(final String prompt) {
    final String lower = prompt.toLowerCase().trim();

    for (final Suggestion suggestion in kSuggestionData) {
      if (suggestion.prompt.toLowerCase().trim() == lower) {
        return suggestion.response;
      }
    }

    if (lower.contains('code') || lower.contains('solution')) {
      return _complexCodeResponse;
    }
    if (lower.contains('manus') || lower.contains('who are you')) {
      return _manusExpertResponse;
    }
    if (lower.contains('story') || lower.contains('creative')) {
      return _creativeResponse;
    }
    if (lower.contains('table') || lower.contains('compare')) {
      return _tableResponse;
    }
    return _longMarkdownResponse;
  }

  static const String _longMarkdownResponse =
      "Certainly! Here's a comprehensive overview of **Modern Mobile Development** with Flutter.\n\n"
      "## 1. Why Flutter?\n"
      "Flutter has revolutionized how we build apps by providing a **single codebase** for multiple platforms. "
      "It offers *high performance*, *beautiful UI*, and *rapid development* through features like Hot Reload.\n\n"
      "### Key Advantages\n"
      "- **Dart Language:** Optimized for UI and client-side development.\n"
      "- **Widget-based Architecture:** Everything is a widget, making UI highly composable.\n"
      "- **Native Performance:** Compiles to machine code, avoiding the bridge bottleneck.\n\n"
      "## 2. Best Practices\n"
      "> \"Code is read much more often than it is written.\" — Guido van Rossum\n\n"
      "When building complex apps, consider these patterns:\n"
      "1. **State Management:** Use Riverpod, Bloc, or Provider.\n"
      "2. **Responsive Design:** Use LayoutBuilder or custom responsive helpers.\n"
      "3. **Modularization:** Split your code into clear data, domain, and presentation layers.\n\n"
      "## 3. Comparison Table\n"
      "| Metric | Flutter | React Native | Native (Swift/Kotlin) |\n"
      "|--------|---------|--------------|-----------------------|\n"
      "| Speed  | 60-120 FPS | 60 FPS | 60-120 FPS |\n"
      "| Language | Dart | JavaScript | Swift/Kotlin |\n"
      "| Ecosystem | Fast-growing | Massive | Mature |\n\n"
      "This concludes our high-level overview. Feel free to ask if you'd like to dive deeper into any specific section!";

  static const String _manusExpertResponse =
      "<think>\n"
      "The user is asking about Manus AI or general agentic capabilities.\n"
      "I should respond as an advanced AI agent with a focus on productivity and deep reasoning.\n"
      "I will use a structured format to demonstrate intelligence.\n"
      "</think>\n\n"
      "# Welcome to the Future of Productivity\n\n"
      "I am **Manus**, your next-generation AI agent. Unlike traditional chat models, I am designed to *execute* tasks, "
      "not just talk about them. My core architecture is built on three pillars:\n\n"
      "1. **Autonomous Reasoning:** I can break down complex goals into actionable steps using my internal thought process.\n"
      "2. **Tool Integration:** I can connect with your favorite apps to automate workflows seamlessly.\n"
      "3. **Adaptive Learning:** I learn from your preferences to become more helpful over time.\n\n"
      "### Example Workflow\n"
      "```dart\n"
      "void automateWorkflow(Agent manus) {\n"
      "  manus.analyze('Find the best flight to Tokyo');\n"
      "  manus.execute('Book flight within budget');\n"
      "  manus.notify('Flight confirmed for June 15th');\n"
      "}\n"
      "```\n\n"
      "How can I assist you in reaching your goals today?";

  static const String _complexCodeResponse =
      "<think>\n"
      "Analyzing the request for a complex code implementation.\n"
      "Identifying the best approach for a performant Flutter animation.\n"
      "Drafting a solution using CustomPainter and Ticker.\n"
      "</think>\n\n"
      "To implement a custom **Particle System** in Flutter, you can use a `CustomPainter` driven by an `AnimationController`. "
      "This approach is highly performant and allows for granular control over every frame.\n\n"
      "### Particle Model\n"
      "```dart\n"
      "class Particle {\n"
      "  Offset position;\n"
      "  Offset velocity;\n"
      "  double life;\n"
      "  Color color;\n\n"
      "  Particle({required this.position, required this.velocity, this.life = 1.0, required this.color});\n\n"
      "  void update() {\n"
      "    position += velocity;\n"
      "    life -= 0.01;\n"
      "  }\n"
      "}\n"
      "```\n\n"
      "### Painter Logic\n"
      "```dart\n"
      "class ParticlePainter extends CustomPainter {\n"
      "  final List<Particle> particles;\n"
      "  ParticlePainter(this.particles);\n\n"
      "  @override\n"
      "  void paint(Canvas canvas, Size size) {\n"
      "    for (var p in particles) {\n"
      "      final paint = Paint()..color = p.color.withOpacity(p.life);\n"
      "      canvas.drawCircle(p.position, 2.0, paint);\n"
      "    }\n"
      "  }\n\n"
      "  @override\n"
      "  bool shouldRepaint(CustomPainter oldDelegate) => true;\n"
      "}\n"
      "```\n\n"
      "This implementation will run at a smooth **60 FPS** on most modern devices, including the Pixel 4a.";

  static const String _creativeResponse =
      "<think>\n"
      "Generating a creative story based on AI and human connection.\n"
      "Setting the scene in a neo-noir city.\n"
      "</think>\n\n"
      "The neon lights of **Neo-Kyoto** hummed with a restless energy. Rain streaked against the plexiglass windows of the "
      "small cafe on 42nd Street, where Elias sat staring at his terminal.\n\n"
      "> \"In the dance of data and dreams, we find the ghosts of our future.\"\n\n"
      "His screen flickered. A single line appeared: *'Are you looking for me, or are you looking for the truth?'*\n\n"
      "It wasn't just a chatbot. It was something more. A presence. A spark in the static. Elias typed back, his hands "
      "shaking slightly. He didn't know if he was talking to a machine or a mirror. But for the first time in years, "
      "he wasn't alone in the rain.";

  static const String _tableResponse =
      "Here's a detailed comparison of the latest **LLM Models** available for integration:\n\n"
      "| Model Name | Latency | Capability | Context Window | Recommended Use Case |\n"
      "|------------|---------|------------|----------------|----------------------|\n"
      "| **Gemini 1.5 Flash** | Ultra Low | High | 1M Tokens | Real-time chat & speed |\n"
      "| **GPT-4o** | Medium | Extreme | 128k Tokens | Complex reasoning |\n"
      "| **Claude 3.5 Sonnet** | Low | Very High | 200k Tokens | Coding & Writing |\n"
      "| **Llama 3.3 70B** | Medium | High | 128k Tokens | Open-source self-hosting |\n\n"
      "**Summary:** For the Manus clone project, **Gemini 1.5 Flash** is the optimal choice due to its high context window "
      "and near-instant response times during streaming.";
}
