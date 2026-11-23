import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class FontService {
  static List<String>? _cachedFonts;

  static const List<String> defaultFallbackFonts = [
    'System Default',
    'Inter',
    'JetBrains Mono',
  ];

  static List<String> get cachedFonts => _cachedFonts ?? defaultFallbackFonts;

  static void init() {
    getSystemFonts();
  }

  static Future<List<String>> getSystemFonts() async {
    if (_cachedFonts != null && _cachedFonts!.isNotEmpty) {
      return _cachedFonts!;
    }

    // Map of normalized lower-case font name -> display name for strict deduplication
    final Map<String, String> uniqueFonts = {};

    // Always include bundled fallback fonts first
    for (final font in defaultFallbackFonts) {
      uniqueFonts[font.toLowerCase()] = font;
    }

    if (!kIsWeb && Platform.isWindows) {
      try {
        final result = await Process.run('reg', [
          'query',
          r'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
        ]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          final styleSuffixRegex = RegExp(
            r'\s+(Bold|Italic|Oblique|Light|Medium|Semibold|SemiBold|ExtraLight|ExtraBold|Black|Book|Regular|Display|Condensed|Narrow|Thin)(\s+(Bold|Italic|Oblique|Regular))*$',
            caseSensitive: false,
          );

          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.isEmpty || !trimmed.contains('REG_SZ')) continue;
            final fontPart = trimmed.split(RegExp(r'\s{2,}REG_SZ'))[0].trim();
            final cleanName = fontPart.replaceAll(RegExp(r'\s*\([^)]*\)$'), '').trim();
            if (cleanName.isNotEmpty && !cleanName.startsWith('@')) {
              final familyName = cleanName.replaceAll(styleSuffixRegex, '').trim();
              if (familyName.isNotEmpty && !familyName.startsWith('@')) {
                final key = familyName.toLowerCase();
                if (!uniqueFonts.containsKey(key)) {
                  uniqueFonts[key] = familyName;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error querying Windows registry fonts: $e');
      }
    } else if (!kIsWeb && Platform.isLinux) {
      try {
        // Query canonical scalable Latin font families to avoid math, symbol, and Asian-only fallback freezes
        final result = await Process.run('fc-list', [
          ':lang=en:scalable=true',
          '-f',
          '%{family[0]}\n',
        ]);
        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          final nonAsciiRegex = RegExp(r'[^\x20-\x7E]');
          final styleSuffixRegex = RegExp(
            r'\s+(Bold|Italic|Oblique|Light|Medium|Semibold|SemiBold|ExtraLight|ExtraBold|Black|Book|Regular|Display|Condensed|Narrow|Thin)(\s+(Bold|Italic|Oblique|Regular))*$',
            caseSensitive: false,
          );

          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.isEmpty) continue;
            // Filter out private fonts, vertical layout variants, non-Latin/symbol names
            if (trimmedLine.startsWith('.') || trimmedLine.startsWith('@')) continue;
            if (nonAsciiRegex.hasMatch(trimmedLine)) continue;
            final lower = trimmedLine.toLowerCase();
            if (lower.contains('math') || lower.contains('symbol') || lower.contains('dingbat')) continue;

            final cleanFamily = trimmedLine.replaceAll(styleSuffixRegex, '').trim();
            if (cleanFamily.isEmpty) continue;

            final key = cleanFamily.toLowerCase();
            if (!uniqueFonts.containsKey(key)) {
              uniqueFonts[key] = cleanFamily;
            }
          }
        }
      } catch (e) {
        debugPrint('Error querying Linux fonts via fc-list: $e');
      }
    }

    final sorted = uniqueFonts.values.toList()
      ..sort((a, b) {
        if (a == 'System Default') return -1;
        if (b == 'System Default') return 1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    _cachedFonts = sorted;
    _prewarmFonts(sorted);
    return sorted;
  }

  static void _prewarmFonts(List<String> fonts) {
    if (kIsWeb) return;
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (index >= fonts.length) {
        timer.cancel();
        return;
      }
      final end = (index + 4 < fonts.length) ? index + 4 : fonts.length;
      for (int i = index; i < end; i++) {
        final font = fonts[i];
        if (font != 'System Default') {
          try {
            final pb = ui.ParagraphBuilder(ui.ParagraphStyle(fontFamily: font))
              ..addText(font);
            final p = pb.build();
            p.layout(const ui.ParagraphConstraints(width: 300));
          } catch (_) {}
        }
      }
      index = end;
    });
  }
}
