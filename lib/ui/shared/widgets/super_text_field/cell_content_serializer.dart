import 'package:super_editor/super_editor.dart';

/// Clean serializer and parser for table cell text content using inline Markdown.
/// Zero legacy Quill/Fleather bloat — saves and reads direct inline Markdown.
class CellContentSerializer {
  /// Parses a stored Markdown string [raw] into an [AttributedText].
  static AttributedText parse(String? raw) {
    if (raw == null || raw.isEmpty) {
      return AttributedText();
    }

    try {
      final lines = raw.split('\n');
      AttributedText result = AttributedText();
      bool openBold = false;

      for (int i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.endsWith('\r')) {
          line = line.substring(0, line.length - 1);
        }
        if (line.endsWith('  ')) {
          line = line.substring(0, line.length - 2);
        }

        // If a bold span was left unclosed on the previous line, carry it over
        if (openBold) {
          line = '**$line';
        }
        if ('**'.allMatches(line).length % 2 != 0) {
          openBold = !openBold;
          if (openBold) {
            line = '$line**';
          }
        }

        final parsedLine = line.isEmpty ? AttributedText() : parseInlineMarkdown(line);
        result = result.copyAndAppend(parsedLine);
        if (i < lines.length - 1) {
          result = result.copyAndAppend(AttributedText('\n'));
        }
      }
      return result;
    } catch (_) {
      return AttributedText(raw);
    }
  }

  /// Serializes an [AttributedText] into an inline Markdown string for SQLite storage.
  ///
  /// Serializes line-by-line so multi-line formatting (e.g. multi-line bold)
  /// produces clean, closed markdown syntax on every line.
  static String serialize(AttributedText text) {
    if (text.isEmpty) {
      return '';
    }

    final plain = text.toPlainText();
    if (!plain.contains('\n')) {
      try {
        return text.toMarkdown();
      } catch (_) {
        return plain;
      }
    }

    final lines = <String>[];
    int start = 0;
    for (int i = 0; i < plain.length; i++) {
      if (plain[i] == '\n') {
        if (start == i) {
          lines.add('');
        } else {
          try {
            lines.add(text.copyText(start, i).toMarkdown());
          } catch (_) {
            lines.add(plain.substring(start, i));
          }
        }
        start = i + 1;
      }
    }
    if (start <= plain.length) {
      if (start == plain.length) {
        lines.add('');
      } else {
        try {
          lines.add(text.copyText(start, plain.length).toMarkdown());
        } catch (_) {
          lines.add(plain.substring(start, plain.length));
        }
      }
    }
    return lines.join('\n');
  }
}
