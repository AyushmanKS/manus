import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/empty_chat_state.dart';
import 'package:manus/presentation/chat/widgets/message_bubble.dart';

class ChatHistoryList extends ConsumerStatefulWidget {
  const ChatHistoryList({required this.onSuggestionTap, super.key});

  final void Function(String text) onSuggestionTap;

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

    final bool nearBottom = _scrollController.offset < 40.0;
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
      WidgetsBinding.instance.addPostFrameCallback((final Duration _) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      });
    }

    if (messages.isEmpty) {
      return EmptyChatState(onSuggestionTap: widget.onSuggestionTap);
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color pillBg = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color pillIcon = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color pillBorder = isDark
        ? AppColors.iconBorderDark
        : AppColors.iconBorderLight;

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: messages.length,
          findChildIndexCallback: (final Key key) {
            final ValueKey<String> valueKey = key as ValueKey<String>;
            final int idx = messages.indexWhere(
              (final ChatMessage m) => m.id == valueKey.value,
            );
            if (idx == -1) return null;
            return messages.length - 1 - idx;
          },
          itemBuilder: (final BuildContext context, final int index) {
            final ChatMessage message = messages[messages.length - 1 - index];
            return MessageBubble(
              key: ValueKey<String>(message.id),
              message: message,
              isLast: index == 0,
            );
          },
        ),
        Positioned(
          bottom: 12.0,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _isAutoScrollEnabled ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child:
                  IgnorePointer(
                        ignoring: _isAutoScrollEnabled,
                        child: GestureDetector(
                          onTap: _jumpToLatest,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: pillBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: pillBorder),
                              boxShadow: <BoxShadow>[
                                const BoxShadow(
                                  color: AppColors.black26,
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: pillIcon,
                              size: 20.0,
                            ),
                          ),
                        ),
                      )
                      .animate(target: _isAutoScrollEnabled ? 0 : 1)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        duration: 200.ms,
                        curve: Curves.easeOutCubic,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
