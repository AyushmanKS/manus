import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/markdown_block_renderer.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isLast,
    super.key,
  });

  final ChatMessage message;
  final bool isLast;

  @override
  Widget build(final BuildContext context) {
    final bool isUser = message.role == MessageRole.user;

    return isUser
        ? _UserBubble(text: message.text)
        : _AssistantBubble(message: message, isLast: isLast);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? AppColors.socialButtonBgDark : AppColors.greyF2;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(left: 48.0, top: 4.0, bottom: 4.0),
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: textColor),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1.0, 1.0),
          duration: 280.ms,
          curve: Curves.easeOutQuart,
        );
  }
}

class _AssistantBubble extends ConsumerWidget {
  const _AssistantBubble({
    required this.message,
    required this.isLast,
  });

  final ChatMessage message;
  final bool isLast;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<MarkdownBlock> blocks = MarkdownSegmenter.parse(message.text);
    final bool isStopped = message.status == MessageStatus.stopped;
    final bool showRegenerate =
        isLast && (isStopped || message.status == MessageStatus.streamed);
    final Color mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.92,
        ),
        margin: const EdgeInsets.only(right: 24.0, top: 4.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (blocks.isNotEmpty)
              ...blocks.indexed.map((final (int, MarkdownBlock) record) {
                final int i = record.$1;
                final MarkdownBlock block = record.$2;
                return MarkdownBlockRenderer(
                  key: ValueKey<String>('${block.type.name}_$i'),
                  block: block,
                );
              }),
            if (isStopped)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.stop_circle_outlined,
                      size: 12.0,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Stopped',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (showRegenerate)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () =>
                      ref.read(chatProvider.notifier).regenerateLastMessage(),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.refresh_rounded,
                        size: 14.0,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Regenerate',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          duration: 280.ms,
          curve: Curves.easeOutQuart,
        );
  }
}
