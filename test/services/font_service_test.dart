import 'package:flutter_test/flutter_test.dart';
import 'package:studyapp/services/font_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FontService defaultFallbackFonts has only System Default, Inter, JetBrains Mono', () {
    expect(FontService.defaultFallbackFonts, [
      'System Default',
      'Inter',
      'JetBrains Mono',
    ]);
  });

  test('FontService getSystemFonts returns clean, deduplicated, sorted list with System Default first', () async {
    final fonts = await FontService.getSystemFonts();
    expect(fonts.isNotEmpty, isTrue);
    expect(fonts.first, equals('System Default'));
    expect(fonts.contains('Inter'), isTrue);
    expect(fonts.contains('JetBrains Mono'), isTrue);

    // Verify deduplication
    final lowerSet = <String>{};
    for (final font in fonts) {
      final lower = font.toLowerCase();
      expect(lowerSet.contains(lower), isFalse, reason: 'Duplicate font found: $font');
      lowerSet.add(lower);
    }

    // Verify alphabetical ordering after System Default
    final tail = fonts.skip(1).toList();
    for (int i = 0; i < tail.length - 1; i++) {
      expect(tail[i].toLowerCase().compareTo(tail[i + 1].toLowerCase()) <= 0, isTrue);
    }
  });
}
