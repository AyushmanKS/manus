import 'dart:async';
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
            ? _UserBubble(message: message)
            : _AssistantBubble(message: message),
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showContextMenu() {
    _removeOverlay();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool copied = false;

    _overlayEntry = OverlayEntry(
      builder: (final BuildContext context) {
        return StatefulBuilder(
          builder:
              (final BuildContext context, final StateSetter setOverlayState) {
                return Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _removeOverlay,
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                    CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      targetAnchor: Alignment.bottomRight,
                      followerAnchor: Alignment.topRight,
                      offset: const Offset(0.0, 6.0),
                      child:
                          Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isDark
                                        ? AppColors.composerBgDark
                                        : AppColors.composerBgLight,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  child: IntrinsicWidth(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _ContextMenuItem(
                                          label: copied ? 'Copied' : 'Copy',
                                          asset: copied
                                              ? AppAssets.checkSvg
                                              : AppAssets.copySvg,
                                          onTap: () async {
                                            if (copied) return;
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: widget.message.text,
                                              ),
                                            );
                                            setOverlayState(
                                              () => copied = true,
                                            );
                                            await Future<void>.delayed(
                                              const Duration(milliseconds: 600),
                                            );
                                            _removeOverlay();
                                          },
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: AppColors.textSecondaryDark
                                              .withValues(alpha: 0.15),
                                        ),
                                        _ContextMenuItem(
                                          label: 'Edit',
                                          asset: AppAssets.pencilSvg,
                                          onTap: () {
                                            ref
                                                .read(
                                                  editingMessageProvider
                                                      .notifier,
                                                )
                                                .startEditing(
                                                  widget.message.id,
                                                  widget.message.text,
                                                );
                                            _removeOverlay();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 150.ms)
                              .scaleXY(
                                begin: 0.85,
                                end: 1.0,
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topRight,
                              ),
                    ),
                  ],
                );
              },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onLongPress: _showContextMenu,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.socialButtonBgDark
                      : AppColors.greyF2,
                  borderRadius: BorderRadius.circular(20.0),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              asset,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: iconColor, fontSize: 10),
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
    final bool isStopped = widget.message.status == MessageStatus.stopped;
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
          Container(
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

    return Container(
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
