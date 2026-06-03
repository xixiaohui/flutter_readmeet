/// Splits markdown content into logical chunks for lazy rendering.
///
/// Each chunk is a self-contained piece of markdown that can be rendered
/// independently by [MarkdownBody]. Chunks are split at natural boundaries:
/// headings, paragraphs, code blocks, blockquotes, and list groups.
class MarkdownChunker {
  /// Splits [markdown] into chunks, each a valid markdown fragment.
  static List<String> chunk(String markdown) {
    if (markdown.isEmpty) return [];

    final lines = markdown.split('\n');
    final chunks = <String>[];
    final buffer = StringBuffer();
    var inCodeBlock = false;
    var inList = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      final nextLine = i + 1 < lines.length ? lines[i + 1] : null;
      final nextTrimmed = nextLine?.trim() ?? '';

      // Toggle code block state
      if (trimmed.startsWith('```')) {
        if (inCodeBlock) {
          // End of code block
          buffer.writeln(line);
          chunks.add(buffer.toString().trim());
          buffer.clear();
          inCodeBlock = false;
          continue;
        } else {
          // Start of code block: flush any pending content
          if (buffer.isNotEmpty) {
            chunks.add(buffer.toString().trim());
            buffer.clear();
          }
          buffer.writeln(line);
          inCodeBlock = true;
          continue;
        }
      }

      if (inCodeBlock) {
        buffer.writeln(line);
        continue;
      }

      // Skip empty leading whitespace
      if (buffer.isEmpty && trimmed.isEmpty) continue;

      // Heading: standalone chunk
      if (trimmed.startsWith('#') && !trimmed.startsWith('# ')) {
        // Could be a tag like ## or ### check for heading pattern # + space
      }
      if (trimmed.startsWith('# ') ||
          trimmed.startsWith('## ') ||
          trimmed.startsWith('### ') ||
          trimmed.startsWith('#### ')) {
        if (buffer.isNotEmpty) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
        buffer.writeln(line);
        // Include subtitle if next line is non-empty and not a heading
        while (i + 1 < lines.length &&
            lines[i + 1].trim().isNotEmpty &&
            !lines[i + 1].trim().startsWith('#')) {
          i++;
          buffer.writeln(lines[i]);
        }
        chunks.add(buffer.toString().trim());
        buffer.clear();
        inList = false;
        continue;
      }

      // Blockquote: group consecutive lines
      if (trimmed.startsWith('>')) {
        if (!inList && buffer.isNotEmpty && !_isBlockquote(buffer)) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
        buffer.writeln(line);
        inList = false;
        continue;
      }

      // List items: group consecutive
      final isListItem =
          trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          trimmed.startsWith('+ ') ||
          RegExp(r'^\d+\. ').hasMatch(trimmed);

      if (isListItem) {
        if (!inList && buffer.isNotEmpty && !_isList(buffer)) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
        buffer.writeln(line);
        inList = true;
        continue;
      }

      // Horizontal rule: standalone
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        if (buffer.isNotEmpty) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
        buffer.writeln(line);
        chunks.add(buffer.toString().trim());
        buffer.clear();
        inList = false;
        continue;
      }

      // Blank line: paragraph boundary
      if (trimmed.isEmpty) {
        if (inList) {
          // End list group
          chunks.add(buffer.toString().trim());
          buffer.clear();
          inList = false;
        } else if (buffer.isNotEmpty && nextTrimmed.isNotEmpty) {
          // Check if next line starts a new block type
          if (!nextTrimmed.startsWith('>') && !_isListItem(nextTrimmed)) {
            chunks.add(buffer.toString().trim());
            buffer.clear();
          }
        }
        continue;
      }

      // Regular paragraph content
      buffer.writeln(line);
      inList = false;

      // Flush if next line is empty or this is the last line
      if (nextLine == null ||
          nextTrimmed.isEmpty ||
          nextTrimmed.startsWith('>') ||
          nextTrimmed.startsWith('# ') ||
          nextTrimmed.startsWith('```')) {
        if (buffer.isNotEmpty) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
      }
    }

    // Flush remaining
    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }

    return chunks;
  }

  static bool _isBlockquote(StringBuffer buffer) {
    return buffer.toString().trim().startsWith('>');
  }

  static bool _isList(StringBuffer buffer) {
    final text = buffer.toString().trim();
    return text.startsWith('- ') ||
        text.startsWith('* ') ||
        text.startsWith('+ ') ||
        RegExp(r'^\d+\. ').hasMatch(text);
  }

  static bool _isListItem(String line) {
    return line.startsWith('- ') ||
        line.startsWith('* ') ||
        line.startsWith('+ ') ||
        RegExp(r'^\d+\. ').hasMatch(line);
  }
}
