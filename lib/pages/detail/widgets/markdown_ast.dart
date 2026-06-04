/// The markdown style of a text segment.
enum MdStyle { body, h1, h2, h3, bold, italic, code, blockquote }

class MarkdownSegment {
  final String text;
  final MdStyle style;
  final bool isBlockEnd;
  final int globalOffset;

  const MarkdownSegment({
    required this.text,
    required this.style,
    required this.isBlockEnd,
    required this.globalOffset,
  });
}

/// Parse markdown source into a flat list of [MarkdownSegment] with
/// accurate global character offsets.
List<MarkdownSegment> parseMarkdownToSegments(String markdown) {
  final segments = <MarkdownSegment>[];
  int offset = 0;
  final lines = markdown.split('\n');

  // Line-by-line parser with context for headings, code blocks, etc.
  int i = 0;
  bool inCodeBlock = false;
  String codeBlockContent = '';
  bool inBlockquote = false;
  String blockquoteContent = '';

  while (i < lines.length) {
    final rawLine = lines[i];
    final trimmed = rawLine.trim();

    // --- Code block (fenced) ---
    if (trimmed.startsWith('```')) {
      if (!inCodeBlock) {
        inCodeBlock = true;
        codeBlockContent = '';
        i++;
        continue;
      } else {
        inCodeBlock = false;
        _addSegment(segments, codeBlockContent, MdStyle.code, false, offset);
        offset += codeBlockContent.length;
        segments.last; // mark as block end by re-adding
        i++;
        continue;
      }
    }

    if (inCodeBlock) {
      codeBlockContent += (codeBlockContent.isEmpty ? '' : '\n') + rawLine;
      i++;
      continue;
    }

    // --- Blockquote ---
    if (trimmed.startsWith('> ')) {
      if (!inBlockquote) {
        inBlockquote = true;
        blockquoteContent = '';
      }
      final content = trimmed.substring(2);
      blockquoteContent += (blockquoteContent.isEmpty ? '' : '\n') + content;
      i++;
      continue;
    } else if (inBlockquote) {
      inBlockquote = false;
      _addSegment(
          segments, blockquoteContent, MdStyle.blockquote, true, offset);
      offset += blockquoteContent.length;
      continue; // re-process current line
    }

    // --- Heading ---
    if (trimmed.startsWith('### ')) {
      final text = trimmed.substring(4);
      _addSegment(segments, text, MdStyle.h3, true, offset);
      offset += text.length;
    } else if (trimmed.startsWith('## ')) {
      final text = trimmed.substring(3);
      _addSegment(segments, text, MdStyle.h2, true, offset);
      offset += text.length;
    } else if (trimmed.startsWith('# ')) {
      final text = trimmed.substring(2);
      _addSegment(segments, text, MdStyle.h1, true, offset);
      offset += text.length;
    } else if (trimmed.isEmpty) {
      // Empty line — skip but don't count as text
    } else {
      // --- Body paragraph ---
      _processInline(segments, trimmed, offset);
      offset += _plainLength(trimmed);
    }

    i++;
  }

  // Close any open blockquote
  if (inBlockquote) {
    _addSegment(segments, blockquoteContent, MdStyle.blockquote, true, offset);
    offset += blockquoteContent.length;
  }

  return segments;
}

void _addSegment(List<MarkdownSegment> list, String text, MdStyle style,
    bool isBlockEnd, int offset) {
  if (text.isNotEmpty) {
    list.add(MarkdownSegment(
      text: text,
      style: style,
      isBlockEnd: isBlockEnd,
      globalOffset: offset,
    ));
  }
}

/// Process inline formatting: bold (**text**) and italic (*text*).
void _processInline(
    List<MarkdownSegment> list, String line, int baseOffset) {
  int pos = 0;

  while (pos < line.length) {
    // Bold: **text**
    final boldStart = line.indexOf('**', pos);
    // Italic: *text* (but not **)
    final italicStart = line.indexOf('*', pos);

    if (boldStart != -1 && (italicStart == -1 || boldStart <= italicStart)) {
      // Text before bold
      if (boldStart > pos) {
        _addSegment(list, line.substring(pos, boldStart), MdStyle.body, false,
            baseOffset + pos);
      }
      final boldEnd = line.indexOf('**', boldStart + 2);
      if (boldEnd != -1) {
        final text = line.substring(boldStart + 2, boldEnd);
        _addSegment(list, text, MdStyle.bold, false, baseOffset + boldStart);
        pos = boldEnd + 2;
      } else {
        // Unclosed bold — treat as plain
        _addSegment(list, line.substring(pos), MdStyle.body, false,
            baseOffset + pos);
        return;
      }
    } else if (italicStart != -1 && line.length > italicStart + 1) {
      // Check it's not the start of **
      if (line[italicStart + 1] == '*') {
        // Actually a bold — handled above, skip
        pos = italicStart + 1;
        continue;
      }
      if (italicStart > pos) {
        _addSegment(list, line.substring(pos, italicStart), MdStyle.body, false,
            baseOffset + pos);
      }
      final italicEnd = line.indexOf('*', italicStart + 1);
      if (italicEnd != -1) {
        final text = line.substring(italicStart + 1, italicEnd);
        _addSegment(
            list, text, MdStyle.italic, false, baseOffset + italicStart);
        pos = italicEnd + 1;
      } else {
        _addSegment(list, line.substring(pos), MdStyle.body, false,
            baseOffset + pos);
        return;
      }
    } else {
      // Rest is plain text
      if (pos < line.length) {
        _addSegment(list, line.substring(pos), MdStyle.body, false,
            baseOffset + pos);
      }
      return;
    }
  }
}

/// Length of text after stripping markdown inline syntax.
int _plainLength(String text) {
  return text
      .replaceAll('**', '')
      .replaceAll('*', '')
      .replaceAll('`', '')
      .length;
}
