import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/app_theme.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';

class MarkdownRenderer extends StatelessWidget {
  final List<MarkdownBlock> blocks;
  final bool isStreaming;

  const MarkdownRenderer({
    required this.blocks,
    required this.isStreaming,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.indexed.map<Widget>((final (int, MarkdownBlock) record) {
        final int i = record.$1;
        final MarkdownBlock block = record.$2;
        return MarkdownBlockItem(
          key: ValueKey<String>('${block.type.name}_$i'),
          block: block,
          isStreaming: isStreaming,
        );
      }).toList(),
    );
  }
}

class MarkdownBlockItem extends StatelessWidget {
  final MarkdownBlock block;
  final bool isStreaming;

  const MarkdownBlockItem({
    required this.block,
    required this.isStreaming,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    switch (block.type) {
      case BlockType.paragraph:
        return _ParagraphBlock(block: block);
      case BlockType.code:
        return _CodeBlock(block: block);
      case BlockType.table:
        return _TableBlock(block: block, isStreaming: isStreaming);
      case BlockType.thinking:
        return _ThinkingBlock(block: block);
    }
  }
}

class _ParagraphBlock extends StatelessWidget {
  final MarkdownBlock block;

  const _ParagraphBlock({required this.block});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return MarkdownBody(
      data: block.content,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: textColor, height: 1.5),
        strong: const TextStyle(fontWeight: FontWeight.w700),
        code: TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 13.0,
          backgroundColor: isDark
              ? AppColors.composerIconBgDark
              : AppColors.composerIconBgLight,
        ),
      ),
      selectable: true,
    );
  }
}

class _CodeBlock extends StatefulWidget {
  final MarkdownBlock block;

  const _CodeBlock({required this.block});

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  String get _rawCode {
    final List<String> lines = widget.block.content.split('\n');
    if (lines.isEmpty) return '';
    final List<String> inner = lines.skip(1).toList();
    if (inner.isNotEmpty && inner.last.trim() == '```') {
      inner.removeLast();
    }
    return inner.join('\n');
  }

  Future<void> _onCopy() async {
    await HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: _rawCode));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? AppColors.socialButtonBgDark
        : AppColors.composerIconBgLight;
    final String lang = widget.block.language ?? 'code';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  lang.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.monoFontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                GestureDetector(
                  onTap: _onCopy,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _copied
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.primary,
                            key: ValueKey<String>('check'),
                          )
                        : (isDark
                              ? const Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: Colors.white54,
                                  key: ValueKey<String>('copy'),
                                )
                              : const Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: Colors.black54,
                                  key: ValueKey<String>('copy'),
                                )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14.0),
            child: Text(
              _rawCode,
              style: TextStyle(
                fontFamily: AppTheme.monoFontFamily,
                fontSize: 13.0,
                height: 1.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingBlock extends StatefulWidget {
  final MarkdownBlock block;

  const _ThinkingBlock({required this.block});

  @override
  State<_ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<_ThinkingBlock> {
  bool _expanded = false;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isStreaming = !widget.block.isComplete;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.composerIconBgDark
            : AppColors.composerIconBgLight,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  if (isStreaming)
                    const _PulsingDot()
                  else
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    isStreaming ? 'Thinking...' : 'Thought process',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Text(
                      widget.block.content,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(final BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            shape: BoxShape.circle,
          ),
        )
        .animate(
          onPlay: (final AnimationController controller) =>
              controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
  }
}

class _TableBlock extends StatelessWidget {
  final MarkdownBlock block;
  final bool isStreaming;

  const _TableBlock({required this.block, required this.isStreaming});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color shimmerBase =
        isDark ? AppColors.composerIconBgDark : AppColors.composerIconBgLight;
    final Color shimmerHighlight =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    if (isStreaming && !block.isComplete) {
      return _TableSkeleton(
        base: shimmerBase,
        highlight: shimmerHighlight,
      );
    }

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: MarkdownBody(
              data: block.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: textColor, fontSize: 14.0),
                tableHead: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
                tableBody: TextStyle(color: textColor, fontSize: 14.0),
                tableBorder: TableBorder.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                tableCellsPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                tableColumnWidth: const FlexColumnWidth(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  final Color base;
  final Color highlight;

  const _TableSkeleton({required this.base, required this.highlight});

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SkeletonRow(base: base, highlight: highlight, isHeader: true),
        const SizedBox(height: 2),
        _SkeletonRow(base: base, highlight: highlight, isHeader: false),
        const SizedBox(height: 2),
        _SkeletonRow(base: base, highlight: highlight, isHeader: false),
        const SizedBox(height: 2),
        _SkeletonRow(base: base, highlight: highlight, isHeader: false),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final Color base;
  final Color highlight;
  final bool isHeader;

  const _SkeletonRow({
    required this.base,
    required this.highlight,
    required this.isHeader,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: List<Widget>.generate(4, (final int i) {
        return Expanded(
          child: Container(
            height: isHeader ? 20.0 : 16.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(4.0),
            ),
          )
              .animate(
                onPlay: (final AnimationController c) =>
                    c.repeat(reverse: true),
              )
              .custom(
                duration: Duration(milliseconds: 900 + i * 120),
                curve: Curves.easeInOut,
                builder: (
                  final BuildContext context,
                  final double value,
                  final Widget? child,
                ) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Color.lerp(base, highlight, value)!,
                      BlendMode.srcATop,
                    ),
                    child: child,
                  );
                },
              ),
        );
      }),
    );
  }
}
