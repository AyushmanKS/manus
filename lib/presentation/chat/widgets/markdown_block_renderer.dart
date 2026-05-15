import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/core/theme/app_theme.dart';
import 'package:manus/core/utils/markdown_segmenter.dart';

class MarkdownBlockRenderer extends StatefulWidget {
  const MarkdownBlockRenderer({required this.block, super.key});

  final MarkdownBlock block;

  @override
  State<MarkdownBlockRenderer> createState() => _MarkdownBlockRendererState();
}

class _MarkdownBlockRendererState extends State<MarkdownBlockRenderer> {
  @override
  Widget build(final BuildContext context) {
    switch (widget.block.type) {
      case BlockType.paragraph:
        return _ParagraphBlock(block: widget.block);
      case BlockType.code:
        return _CodeBlock(block: widget.block);
      case BlockType.table:
        return _TableBlock(block: widget.block);
      case BlockType.thinking:
        return _ThinkingBlock(block: widget.block);
    }
  }
}

class _ParagraphBlock extends StatelessWidget {
  const _ParagraphBlock({required this.block});

  final MarkdownBlock block;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return MarkdownBody(
      data: block.content,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
        strong: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
        em: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor,
          fontStyle: FontStyle.italic,
        ),
        code: TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 13.0,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          backgroundColor: isDark
              ? AppColors.composerIconBgDark
              : AppColors.composerIconBgLight,
        ),
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isDark
                  ? AppColors.iconBorderDark
                  : AppColors.iconBorderLight,
              width: 3.0,
            ),
          ),
        ),
      ),
      selectable: true,
    );
  }
}

class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.block});

  final MarkdownBlock block;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  String get _rawCode {
    final List<String> lines = widget.block.content.split('\n');
    final List<String> inner = lines.skip(1).toList();
    if (inner.isNotEmpty && inner.last.trim() == '```') {
      inner.removeLast();
    }
    return inner.join('\n');
  }

  Future<void> _onCopy() async {
    await HapticFeedback.lightImpact();
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
    final Color labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color iconColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final String lang = widget.block.language ?? 'code';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 8.0, 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  lang,
                  style: TextStyle(
                    fontFamily: AppTheme.monoFontFamily,
                    fontSize: 12.0,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: _onCopy,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _copied
                          ? const Icon(
                              Icons.check_rounded,
                              key: ValueKey<String>('check'),
                              size: 16.0,
                              color: AppColors.primary,
                            )
                          : Icon(
                              Icons.copy_rounded,
                              key: const ValueKey<String>('copy'),
                              size: 16.0,
                              color: iconColor,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14.0),
            child: Text(
              _rawCode,
              style: TextStyle(
                fontFamily: AppTheme.monoFontFamily,
                fontSize: 13.0,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.block});

  final MarkdownBlock block;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: MarkdownBody(
        data: block.content,
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
          tableHead: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
          tableBody: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
          tableBorder: TableBorder.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1.0,
          ),
          tableCellsPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
        ),
      ),
    );
  }
}

class _ThinkingBlock extends StatefulWidget {
  const _ThinkingBlock({required this.block});

  final MarkdownBlock block;

  @override
  State<_ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<_ThinkingBlock> {
  bool _expanded = false;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color bg = isDark
        ? AppColors.composerIconBgDark
        : AppColors.composerIconBgLight;
    final bool isStreaming = !widget.block.isComplete;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Row(
                children: <Widget>[
                  if (isStreaming)
                    _PulsingDot(color: labelColor)
                  else
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 14.0,
                      color: labelColor,
                    ),
                  const SizedBox(width: 8.0),
                  Text(
                    isStreaming ? 'Thinking...' : 'Thought process',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.0,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                    child: Text(
                      widget.block.content,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: textColor,
                        height: 1.5,
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
  const _PulsingDot({required this.color});

  final Color color;

  @override
  Widget build(final BuildContext context) {
    return Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (final AnimationController c) => c.repeat())
        .fadeOut(begin: 1.0, duration: 800.ms, curve: Curves.easeInOut)
        .then()
        .fadeIn(duration: 800.ms, curve: Curves.easeInOut);
  }
}
