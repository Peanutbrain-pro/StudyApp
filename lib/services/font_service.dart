import 'dart:io';
import 'package:flutter/foundation.dart';

class FontService {
  static List<String>? _cachedFonts;

  static const List<String> defaultFallbackFonts = [
    'System Default',
    'Segoe UI',
    'Aptos',
    'Arial',
    'Bahnschrift',
    'Calibri',
    'Cambria',
    'Cascadia Code',
    'Cascadia Mono',
    'Comic Sans MS',
    'Consolas',
    'Constantia',
    'Corbel',
    'Courier New',
    'Fira Code',
    'Franklin Gothic Medium',
    'Georgia',
    'Impact',
    'Inter',
    'JetBrains Mono',
    'Lucida Console',
    'Lucida Sans',
    'Palatino Linotype',
    'Roboto',
    'Segoe Print',
    'Segoe Script',
    'Sitka',
    'Sylfaen',
    'Tahoma',
    'Times New Roman',
    'Trebuchet MS',
    'Verdana',
  ];

  static List<String> get cachedFonts => _cachedFonts ?? defaultFallbackFonts;

  static void init() {
    getSystemFonts();
  }

  static Future<List<String>> getSystemFonts() async {
    if (_cachedFonts != null && _cachedFonts!.isNotEmpty) {
      return _cachedFonts!;
    }

    final Set<String> fontNames = {'System Default'};

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
            if (cleanName.isNotEmpty) {
              final familyName = cleanName.replaceAll(styleSuffixRegex, '').trim();
              if (familyName.isNotEmpty) {
                fontNames.add(familyName);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error querying Windows registry fonts: $e');
      }
    }

    fontNames.addAll(defaultFallbackFonts);

    final sorted = fontNames.toList()
      ..sort((a, b) {
        if (a == 'System Default') return -1;
        if (b == 'System Default') return 1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    _cachedFonts = sorted;
    return sorted;
  }
}
