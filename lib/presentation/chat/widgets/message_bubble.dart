import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/markdown_renderer.dart';

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

  void _showContextMenu(final BuildContext context, final ChatMessage message) {
    HapticFeedback.mediumImpact();
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (final BuildContext context) => _ContextMenuOverlay(
        message: message,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

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
        child: GestureDetector(
          onLongPress: () => _showContextMenu(context, message),
          child: isUser
              ? _UserBubble(message: message)
              : _AssistantBubble(message: message),
        ),
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

class _UserBubble extends ConsumerStatefulWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  ConsumerState<_UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends ConsumerState<_UserBubble> {
  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(4.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SelectionArea(
                  child: Text(
                    widget.message.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (widget.message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'edited',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextMenuOverlay extends ConsumerStatefulWidget {
  const _ContextMenuOverlay({required this.message, required this.onDismiss});

  final ChatMessage message;
  final VoidCallback onDismiss;

  @override
  ConsumerState<_ContextMenuOverlay> createState() =>
      _ContextMenuOverlayState();
}

class _ContextMenuOverlayState extends ConsumerState<_ContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _blurAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.linear),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAssistant = widget.message.role == MessageRole.assistant;

    return GestureDetector(
      onTap: _dismiss,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _blurAnimation,
          builder: (final BuildContext context, final Widget? child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8 * _blurAnimation.value,
                sigmaY: 8 * _blurAnimation.value,
              ),
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.3 * _blurAnimation.value,
                ),
                child: child,
              ),
            );
          },
          child: Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(_animation),
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.composerBgDark
                        : AppColors.composerBgLight,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _MenuAction(
                        label: 'Copy',
                        icon: AppAssets.copySvg,
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.message.text),
                          );
                          HapticFeedback.lightImpact();
                          _dismiss();
                        },
                      ),
                      if (isAssistant)
                        _MenuAction(
                          label: 'Retry',
                          icon: AppAssets.plusSvg,
                          onTap: () {
                            ref
                                .read(chatProvider.notifier)
                                .regenerate(widget.message.id);
                            _dismiss();
                          },
                        ),
                      _MenuAction(
                        label: 'Delete',
                        icon: AppAssets.deleteSvg,
                        isDestructive: true,
                        onTap: () {
                          ref
                              .read(chatProvider.notifier)
                              .deleteMessage(widget.message.id);
                          _dismiss();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final String icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isDestructive
        ? Colors.red
        : (isDark ? Colors.white : Colors.black);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              icon,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatefulWidget {
  const _AssistantBubble({required this.message});

  final ChatMessage message;

  @override
  State<_AssistantBubble> createState() => _AssistantBubbleState();
}

class _AssistantBubbleState extends State<_AssistantBubble> {
  final Map<int, Widget> _blockCache = <int, Widget>{};

  @override
  Widget build(final BuildContext context) {
    final bool isStreaming = widget.message.status == MessageStatus.sending;
    final bool isStopped =
        widget.message.status == MessageStatus.stopped ||
        widget.message.status == MessageStatus.interrupted;
    final List<MarkdownBlock> blocks = MarkdownSegmenter.parse(
      widget.message.text,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBlockList(blocks, isStreaming),
            if (isStreaming) const _StreamingCaret(),
            if (isStopped) const _StoppedBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockList(
    final List<MarkdownBlock> blocks,
    final bool isStreaming,
  ) {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final MarkdownBlock block = blocks[i];
      final bool isLastBlock = i == blocks.length - 1;
      final bool shouldCache = block.isComplete && !isLastBlock;

      if (shouldCache && _blockCache.containsKey(i)) {
        children.add(_blockCache[i]!);
        continue;
      }

      final Widget rendered = KeyedSubtree(
        key: ValueKey<String>('block_${block.type.name}_$i'),
        child: MarkdownBlockItem(block: block, isStreaming: isStreaming),
      );

      if (shouldCache) {
        _blockCache[i] = rendered;
      }

      children.add(rendered);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _StoppedBadge extends StatelessWidget {
  const _StoppedBadge();

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Generation stopped',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _StreamingCaret extends StatelessWidget {
  const _StreamingCaret();

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color caretColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 2.0,
          height: 14.0,
          margin: const EdgeInsets.only(top: 2.0, left: 2.0),
          decoration: BoxDecoration(
            color: caretColor,
            borderRadius: BorderRadius.circular(1.0),
          ),
        )
        .animate(
          onPlay: (final AnimationController c) => c.repeat(reverse: true),
        )
        .fadeIn(duration: 530.ms);
  }
}
