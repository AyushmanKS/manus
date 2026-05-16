import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/notifiers/chat_notifier.dart';
import 'package:manus/presentation/chat/widgets/markdown_renderer.dart';
import 'package:share_plus/share_plus.dart';

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

class _UserBubble extends ConsumerWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget bubbleContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message.text, style: Theme.of(context).textTheme.bodyLarge),
          if (message.isEdited)
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
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: CupertinoContextMenu(
          actions: <Widget>[
            CupertinoContextMenuAction(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(editingMessageProvider.notifier)
                    .startEditing(message.id, message.text);
              },
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    AppAssets.pencilSvg,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit'),
                ],
              ),
            ),
            CupertinoContextMenuAction(
              onPressed: () {
                Navigator.pop(context);
                unawaited(Clipboard.setData(ClipboardData(text: message.text)));
                unawaited(HapticFeedback.lightImpact());
              },
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    AppAssets.copySvg,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Copy'),
                ],
              ),
            ),
          ],
          child: bubbleContent,
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
  final GlobalKey<SelectableRegionState> _selectionKey =
      GlobalKey<SelectableRegionState>();
  final Map<int, Widget> _blockCache = <int, Widget>{};

  void _shareMessage(final BuildContext context) {
    unawaited(Share.share(widget.message.text));
  }

  Widget _buildContextMenu(
    final BuildContext context,
    final SelectableRegionState selectableRegionState,
  ) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: <ContextMenuButtonItem>[
        ContextMenuButtonItem(
          label: 'Share',
          onPressed: () {
            selectableRegionState.hideToolbar();
            _shareMessage(context);
          },
        ),
        ContextMenuButtonItem(
          label: 'Copy',
          onPressed: () {
            Actions.invoke(context, CopySelectionTextIntent.copy);
            unawaited(HapticFeedback.lightImpact());
          },
        ),
        ContextMenuButtonItem(
          label: 'Select text',
          onPressed: () {
            selectableRegionState.selectAll(SelectionChangedCause.toolbar);
          },
        ),
        ContextMenuButtonItem(
          label: 'Report',
          onPressed: () {
            AppLogger.info('Report message: ${widget.message.id}');
            selectableRegionState.hideToolbar();
          },
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isStreaming = widget.message.status == MessageStatus.sending;
    final bool isStopped =
        widget.message.status == MessageStatus.stopped ||
        widget.message.status == MessageStatus.interrupted;
    final List<MarkdownBlock> blocks = MarkdownSegmenter.parse(
      widget.message.text,
    );

    final Widget bubbleContentColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildBlockList(blocks, isStreaming),
        if (isStreaming) const _StreamingCaret(),
        if (isStopped) const _StoppedBadge(),
      ],
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: SelectionArea(
          key: _selectionKey,
          selectionControls: EmptyTextSelectionControls(),
          contextMenuBuilder:
              (
                final BuildContext context,
                final SelectableRegionState selectableRegionState,
              ) => _buildContextMenu(context, selectableRegionState),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () {
                unawaited(HapticFeedback.mediumImpact());
                WidgetsBinding.instance.addPostFrameCallback((final _) {
                  if (!mounted) return;
                  _selectionKey.currentState?.selectAll(
                    SelectionChangedCause.toolbar,
                  );
                });
              },
              child: bubbleContentColumn,
            ),
          ),
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
      mainAxisSize: MainAxisSize.min,
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
