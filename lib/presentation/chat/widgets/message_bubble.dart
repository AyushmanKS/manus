import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/widgets/markdown_renderer.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLast;

  const MessageBubble({required this.message, required this.isLast, super.key});

  @override
  Widget build(final BuildContext context) {
    final bool isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: isUser
          ? _UserBubble(text: message.text)
          : _AssistantBubble(message: message, isLast: isLast),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.socialButtonBgDark : AppColors.greyF2,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLast;

  const _AssistantBubble({required this.message, required this.isLast});

  @override
  Widget build(final BuildContext context) {
    final List<MarkdownBlock> blocks = MarkdownSegmenter.parse(message.text);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: MarkdownRenderer(blocks: blocks),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
