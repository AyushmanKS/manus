import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manus/core/services/haptic_service.dart';
import 'package:manus/core/utils/app_logger.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';
import 'package:manus/data/models/chat_message.dart';
import 'package:manus/presentation/chat/widgets/markdown_renderer.dart';
import 'package:manus/presentation/chat/widgets/bubbles/streaming_caret.dart';
import 'package:manus/presentation/chat/widgets/bubbles/stopped_badge.dart';
import 'package:share_plus/share_plus.dart';

class AssistantBubble extends StatefulWidget {
  const AssistantBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  State<AssistantBubble> createState() => _AssistantBubbleState();
}

class _AssistantBubbleState extends State<AssistantBubble> {
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
            unawaited(HapticService.light());
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
        if (isStreaming) const StreamingCaret(),
        if (isStopped) const StoppedBadge(),
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
                unawaited(HapticService.medium());
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
