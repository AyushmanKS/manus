import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/bubbles/user_bubble.dart';
import 'package:manus/presentation/chat/widgets/bubbles/assistant_bubble.dart';

class MessageBubble extends ConsumerStatefulWidget {
  const MessageBubble({
    required this.messageId,
    required this.index,
    super.key,
  });

  final String messageId;
  final int index;

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  bool _hasAnimated = false;

  @override
  Widget build(final BuildContext context) {
    final ChatMessage? message = ref.watch(
      chatMessageByIdProvider(widget.messageId),
    );

    if (message == null) return const SizedBox.shrink();

    final bool isUser = message.role == MessageRole.user;
    final int staggerIndex = widget.index % 3;
    final Duration staggerDelay = Duration(milliseconds: staggerIndex * 60);

    Widget child = RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: isUser
            ? UserBubble(message: message)
            : AssistantBubble(message: message),
      ),
    );

    if (!_hasAnimated) {
      _hasAnimated = true;
      child = child
          .animate()
          .fadeIn(duration: 250.ms, delay: staggerDelay)
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1.0, 1.0),
            duration: 350.ms,
            delay: staggerDelay,
            curve: Curves.easeOutBack,
          );
    }

    return child;
  }
}
