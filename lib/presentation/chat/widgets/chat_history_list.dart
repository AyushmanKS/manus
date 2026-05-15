import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/message_bubble.dart';

class ChatHistoryList extends ConsumerStatefulWidget {
  const ChatHistoryList({super.key});

  @override
  ConsumerState<ChatHistoryList> createState() => _ChatHistoryListState();
}

class _ChatHistoryListState extends ConsumerState<ChatHistoryList> {
  late final ScrollController _scrollController;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double distanceFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;

    if (distanceFromBottom > 40.0 && _autoScroll) {
      setState(() => _autoScroll = false);
    } else if (distanceFromBottom <= 40.0 && !_autoScroll) {
      setState(() => _autoScroll = true);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    setState(() => _autoScroll = true);
  }

  void _trackNewToken() {
    if (!_autoScroll || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final List<ChatMessage> messages = ref.watch(chatProvider);
    final bool isStreaming = ref.watch(chatIsStreamingProvider);

    if (isStreaming) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _trackNewToken();
      });
    }

    if (messages.isEmpty) return const SizedBox.shrink();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: messages.length,
          itemBuilder: (final BuildContext context, final int index) {
            final ChatMessage message = messages[index];
            return MessageBubble(
              key: ValueKey<String>(message.id),
              messageId: message.id,
              index: index,
            );
          },
        ),
        if (!_autoScroll)
          Positioned(
            bottom: 12.0,
            left: 0,
            right: 0,
            child: Center(
              child: _JumpToLatestPill(isDark: isDark, onTap: _scrollToBottom),
            ),
          ),
      ],
    );
  }
}

class _JumpToLatestPill extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _JumpToLatestPill({required this.isDark, required this.onTap});

  @override
  Widget build(final BuildContext context) {
    final Color bg = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color borderColor = isDark ? Colors.white12 : Colors.black12;

    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.0,
                  color: textColor,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Jump to latest',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(
          begin: 0.3,
          end: 0.0,
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
