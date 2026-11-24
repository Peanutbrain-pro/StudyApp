import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';
import 'package:studyapp/ui/shared/widgets/super_text_field/cell_content_serializer.dart';

void main() {
  group('CellContentSerializer', () {
    test('parses null and empty string into empty AttributedText', () {
      expect(CellContentSerializer.parse(null).isEmpty, isTrue);
      expect(CellContentSerializer.parse('').isEmpty, isTrue);
    });

    test('serializes empty AttributedText to empty string', () {
      expect(CellContentSerializer.serialize(AttributedText()), equals(''));
    });

    test('parses and serializes plain text', () {
      final parsed = CellContentSerializer.parse('Simple plain text');
      expect(parsed.toPlainText(), equals('Simple plain text'));
      expect(parsed.spans.markers.isEmpty, isTrue);

      final serialized = CellContentSerializer.serialize(parsed);
      expect(serialized, equals('Simple plain text'));
    });

    test('parses and serializes multiline text with newlines', () {
      const multiline = 'Line 1\nLine 2\n\nLine 3';
      final parsed = CellContentSerializer.parse(multiline);
      final serialized = CellContentSerializer.serialize(parsed);
      final roundTrip = CellContentSerializer.parse(serialized);
      expect(roundTrip.toPlainText(), equals(multiline));
    });

    test('serializes multiline bold line-by-line and roundtrips without leaking **', () {
      final attributed = AttributedText(
        'Line 1\nLine 2',
        AttributedSpans(
          attributions: [
            const SpanMarker(attribution: boldAttribution, offset: 0, markerType: SpanMarkerType.start),
            const SpanMarker(attribution: boldAttribution, offset: 12, markerType: SpanMarkerType.end),
          ],
        ),
      );
      final serialized = CellContentSerializer.serialize(attributed);
      expect(serialized, equals('**Line 1**\n**Line 2**'));

      final parsed = CellContentSerializer.parse(serialized);
      expect(parsed.toPlainText(), equals('Line 1\nLine 2'));
      expect(parsed.hasAttributionAt(0, attribution: boldAttribution), isTrue);
      expect(parsed.hasAttributionAt(7, attribution: boldAttribution), isTrue);
    });

    test('parses markdown formatting', () {
      final parsed = CellContentSerializer.parse('**Bold** and *Italic*');
      expect(parsed.toPlainText(), equals('Bold and Italic'));
      expect(parsed.hasAttributionAt(0, attribution: boldAttribution), isTrue);
      expect(parsed.hasAttributionAt(9, attribution: italicsAttribution), isTrue);

      final serialized = CellContentSerializer.serialize(parsed);
      expect(serialized, equals('**Bold** and *Italic*'));
    });
  });
}
