enum BlockType { paragraph, code, table, thinking }

class MarkdownBlock {
  const MarkdownBlock({
    required this.type,
    required this.content,
    required this.isComplete,
    this.language,
  });

  final BlockType type;
  final String content;
  final bool isComplete;
  final String? language;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is MarkdownBlock &&
          type == other.type &&
          content == other.content &&
          isComplete == other.isComplete &&
          language == other.language;

  @override
  int get hashCode => Object.hash(type, content, isComplete, language);
}

class MarkdownSegmenter {
  MarkdownSegmenter._();

  static const String thinkingPrefix = '__THINKING__';

  static final RegExp _thinkOpen = RegExp(r'<think>', caseSensitive: false);
  static final RegExp _thinkClose = RegExp(r'</think>', caseSensitive: false);
  static final RegExp _codeFence = RegExp(r'^```(\w*)');
  static final RegExp _tableRow = RegExp(r'^\|.+\|');

  static List<MarkdownBlock> parse(final String fullText) {
    if (fullText.isEmpty) return <MarkdownBlock>[];

    final List<MarkdownBlock> blocks = <MarkdownBlock>[];
    final List<String> lines = fullText.split('\n');

    final StringBuffer buffer = StringBuffer();
    BlockType currentType = BlockType.paragraph;
    String? codeLanguage;
    bool inCode = false;
    bool inThink = false;
    bool inTable = false;

    void flush({required final bool complete}) {
      final String content = buffer.toString().trimRight();
      if (content.isEmpty) return;
      blocks.add(
        MarkdownBlock(
          type: currentType,
          content: content,
          isComplete: complete,
          language: currentType == BlockType.code ? codeLanguage : null,
        ),
      );
      buffer.clear();
      codeLanguage = null;
    }

    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      final bool isLast = i == lines.length - 1;

      if (!inCode && !inThink && line.startsWith(thinkingPrefix)) {
        if (currentType != BlockType.thinking) {
          flush(complete: true);
          currentType = BlockType.thinking;
          inThink = true;
        }
        buffer.writeln(line.substring(thinkingPrefix.length));
        if (isLast) flush(complete: false);
        continue;
      }

      if (inThink && !line.startsWith(thinkingPrefix)) {
        flush(complete: true);
        inThink = false;
        currentType = BlockType.paragraph;
      }

      if (!inCode && !inThink && _thinkOpen.hasMatch(line)) {
        flush(complete: true);
        inThink = true;
        currentType = BlockType.thinking;
        final String after = line.replaceFirst(_thinkOpen, '');
        if (after.isNotEmpty) buffer.writeln(after);
        continue;
      }

      if (inThink && currentType == BlockType.thinking) {
        if (_thinkClose.hasMatch(line)) {
          final String before = line.split(_thinkClose).first;
          if (before.isNotEmpty) buffer.writeln(before);
          flush(complete: true);
          inThink = false;
          currentType = BlockType.paragraph;
        } else {
          buffer.writeln(line);
        }
        continue;
      }

      final RegExpMatch? fenceMatch = _codeFence.firstMatch(line);
      if (!inCode && fenceMatch != null) {
        if (inTable) {
          flush(complete: true);
          inTable = false;
        } else {
          flush(complete: true);
        }
        inCode = true;
        currentType = BlockType.code;
        codeLanguage = fenceMatch.group(1)?.isNotEmpty == true
            ? fenceMatch.group(1)
            : null;
        buffer.writeln(line);
        continue;
      }

      if (inCode) {
        buffer.writeln(line);
        if (line.trim() == '```') {
          flush(complete: !isLast);
          inCode = false;
          currentType = BlockType.paragraph;
        }
        continue;
      }

      final bool isTableRow = _tableRow.hasMatch(line);

      if (isTableRow && !inTable) {
        flush(complete: true);
        inTable = true;
        currentType = BlockType.table;
        buffer.writeln(line);
        continue;
      }

      if (inTable) {
        if (isTableRow || line.trim().startsWith('|')) {
          buffer.writeln(line);
        } else {
          flush(complete: true);
          inTable = false;
          currentType = BlockType.paragraph;
          buffer.writeln(line);
        }
        continue;
      }

      buffer.writeln(line);
    }

    flush(complete: false);

    for (int i = 0; i < blocks.length - 1; i++) {
      final MarkdownBlock b = blocks[i];
      if (!b.isComplete) {
        blocks[i] = MarkdownBlock(
          type: b.type,
          content: b.content,
          isComplete: true,
          language: b.language,
        );
      }
    }

    return blocks;
  }
}
