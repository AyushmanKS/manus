import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  bool _isAutoScrollEnabled = true;

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
    final ScrollDirection direction =
        _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.forward) {
      if (_isAutoScrollEnabled) {
        setState(() => _isAutoScrollEnabled = false);
      }
      return;
    }

    final bool nearBottom = _scrollController.offset < 50.0;
    if (nearBottom && !_isAutoScrollEnabled) {
      setState(() => _isAutoScrollEnabled = true);
    }
  }

  void _jumpToLatest() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final List<ChatMessage> messages = ref.watch(chatProvider);

    if (_isAutoScrollEnabled && messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      });
    }

    if (messages.isEmpty) return const SizedBox.shrink();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: messages.length,
          itemBuilder: (final BuildContext context, final int index) {
            final ChatMessage message = messages[messages.length - 1 - index];
            return MessageBubble(
              key: ValueKey<String>(message.id),
              message: message,
              isLast: index == 0,
            );
          },
        ),
        if (!_isAutoScrollEnabled)
          Positioned(
            bottom: 12.0,
            left: 0,
            right: 0,
            child:
                Center(
                      child: GestureDetector(
                        onTap: _jumpToLatest,
                        child: Container(
                          width: 38.0,
                          height: 38.0,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.composerBgDark
                                : AppColors.composerBgLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark ? Colors.white70 : Colors.black87,
                            size: 24.0,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeOutBack,
                    ),
          ),
      ],
    );
  }
}
