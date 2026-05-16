import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/message_bubble.dart';

class ChatHistoryList extends ConsumerStatefulWidget {
  const ChatHistoryList({super.key});

  @override
  ChatHistoryListState createState() => ChatHistoryListState();
}

class ChatHistoryListState extends ConsumerState<ChatHistoryList> {
  late final ScrollController _scrollController;
  final ValueNotifier<bool> _autoScrollNotifier = ValueNotifier<bool>(true);
  bool _userIsScrolling = false;
  bool _forcingScroll = false;
  bool _keyboardScrolling = false;
  int _prevMessageCount = 0;
  int _prevLastTextLength = 0;

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
    _autoScrollNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition pos = _scrollController.position;
    if (pos.outOfRange) return;

    final ScrollDirection direction = pos.userScrollDirection;
    _userIsScrolling = direction != ScrollDirection.idle;

    if (direction == ScrollDirection.forward) {
      if (_autoScrollNotifier.value) {
        _autoScrollNotifier.value = false;
      }
      return;
    }

    final double distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    if (distanceFromBottom <= 40.0 && !_autoScrollNotifier.value) {
      _autoScrollNotifier.value = true;
    }
  }

  void _checkAndEngageAutoScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition pos = _scrollController.position;
    final double distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    if (distanceFromBottom <= 40.0) {
      _autoScrollNotifier.value = true;
    }
  }

  void _animateToBottom() {
    if (!_autoScrollNotifier.value) return;
    if (!_scrollController.hasClients) return;
    if (_userIsScrolling && !_keyboardScrolling) return;
    if (_forcingScroll) return;
    if (_scrollController.position.isScrollingNotifier.value &&
        !_keyboardScrolling) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
    );
  }

  void forceScrollToBottom() {
    if (!_scrollController.hasClients) return;
    _userIsScrolling = false;
    _forcingScroll = true;
    _autoScrollNotifier.value = true;
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          HapticFeedback.lightImpact();
          if (mounted) {
            _checkAndEngageAutoScroll();
            _forcingScroll = false;
          }
        });
  }

  void scrollToBottom() {
    if (_autoScrollNotifier.value) _animateToBottom();
  }

  void doubleFrameScrollToBottom() {
    if (!_autoScrollNotifier.value) return;
    _keyboardScrolling = true;
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animateToBottom();
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _animateToBottom();
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          _animateToBottom();
          _keyboardScrolling = false;
          _checkAndEngageAutoScroll();
        });
      });
    });
  }

  void onScrollMetricsChanged() {
    if (!_autoScrollNotifier.value) return;
    _keyboardScrolling = true;
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _animateToBottom();
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _animateToBottom();
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          _animateToBottom();
          _keyboardScrolling = false;
          _checkAndEngageAutoScroll();
        });
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    final List<ChatMessage> messages = ref.watch(chatProvider);

    ref.listen<List<ChatMessage>>(chatProvider, (
      final List<ChatMessage>? prev,
      final List<ChatMessage> next,
    ) {
      if (!_autoScrollNotifier.value) return;
      final int nextCount = next.length;
      final int nextLastLen = next.isNotEmpty ? next.last.text.length : 0;
      final bool grew =
          nextCount > _prevMessageCount || nextLastLen > _prevLastTextLength;
      _prevMessageCount = nextCount;
      _prevLastTextLength = nextLastLen;
      if (grew) {
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          _animateToBottom();
          WidgetsBinding.instance.addPostFrameCallback((final _) {
            _animateToBottom();
            WidgetsBinding.instance.addPostFrameCallback((final _) {
              _animateToBottom();
              _checkAndEngageAutoScroll();
            });
          });
        });
      }
    });

    if (messages.isEmpty) return const SizedBox.shrink();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          itemCount: messages.length,
          itemBuilder: (final BuildContext context, final int index) {
            final ChatMessage message = messages[index];
            final Widget bubble = MessageBubble(
              key: ValueKey<String>(message.id),
              messageId: message.id,
              index: index,
            );
            if (index >= messages.length - 2) {
              return bubble
                  .animate()
                  .fadeIn(duration: 220.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.06,
                    end: 0.0,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scaleXY(
                    begin: 0.94,
                    duration: 320.ms,
                    curve: Curves.easeOutBack,
                  );
            }
            return bubble;
          },
        ),
        Positioned(
          bottom: 12.0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<bool>(
            valueListenable: _autoScrollNotifier,
            builder:
                (
                  final BuildContext context,
                  final bool autoScroll,
                  final Widget? _,
                ) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (
                          final Widget child,
                          final Animation<double> animation,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0.0, 0.3),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                          );
                        },
                    child: autoScroll
                        ? const SizedBox.shrink(key: ValueKey<bool>(true))
                        : Center(
                            key: const ValueKey<bool>(false),
                            child: _JumpToLatestPill(
                              isDark: isDark,
                              onTap: forceScrollToBottom,
                            ),
                          ),
                  );
                },
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SvgPicture.asset(
          AppAssets.downArrowSvg,
          width: 20.0,
          height: 20.0,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
