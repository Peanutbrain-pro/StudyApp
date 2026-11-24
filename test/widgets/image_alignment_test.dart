import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Image Alignment Persistence in SuperEditor', () {
    test('Image alignment round-trips through Markdown serialization and deserialization', () {
      // 1. Center alignment (default, no hash fragment)
      final docCenter = MutableDocument(nodes: [
        ImageNode(
          id: 'img1',
          imageUrl: 'sources/photo.png',
          expectedBitmapSize: const ExpectedSize(400, 300),
        ),
      ]);
      final mdCenter = serializeDocumentToMarkdown(docCenter);
      expect(mdCenter, equals('![](sources/photo.png =400x300)'));

      final deserializedCenter = deserializeMarkdownToDocument(mdCenter);
      final centerNode = deserializedCenter.firstWhere((n) => n is ImageNode) as ImageNode;
      expect(centerNode.imageUrl, equals('sources/photo.png'));
      expect(centerNode.imageUrl.contains('#left'), isFalse);
      expect(centerNode.imageUrl.contains('#right'), isFalse);

      // 2. Left alignment (#left hash fragment)
      final docLeft = MutableDocument(nodes: [
        ImageNode(
          id: 'img2',
          imageUrl: 'sources/photo.png#left',
          expectedBitmapSize: const ExpectedSize(400, 300),
        ),
      ]);
      final mdLeft = serializeDocumentToMarkdown(docLeft);
      expect(mdLeft, equals('![](sources/photo.png#left =400x300)'));

      final deserializedLeft = deserializeMarkdownToDocument(mdLeft);
      final leftNode = deserializedLeft.firstWhere((n) => n is ImageNode) as ImageNode;
      expect(leftNode.imageUrl, equals('sources/photo.png#left'));
      expect(leftNode.imageUrl.contains('#left'), isTrue);

      // 3. Right alignment (#right hash fragment)
      final docRight = MutableDocument(nodes: [
        ImageNode(
          id: 'img3',
          imageUrl: 'sources/photo.png#right',
        ),
      ]);
      final mdRight = serializeDocumentToMarkdown(docRight);
      expect(mdRight, equals('![](sources/photo.png#right)'));

      final deserializedRight = deserializeMarkdownToDocument(mdRight);
      final rightNode = deserializedRight.firstWhere((n) => n is ImageNode) as ImageNode;
      expect(rightNode.imageUrl, equals('sources/photo.png#right'));
      expect(rightNode.imageUrl.contains('#right'), isTrue);
    });

    test('Alignment toggle cleans previous alignment and does not corrupt path with existing hashes', () {
      String cleanUrl(String url) => url.replaceAll(RegExp(r'#(left|right|center)$'), '');

      expect(cleanUrl('sources/my#photo.png#left'), equals('sources/my#photo.png'));
      expect(cleanUrl('sources/my#photo.png#right'), equals('sources/my#photo.png'));
      expect(cleanUrl('sources/my#photo.png#center'), equals('sources/my#photo.png'));
      expect(cleanUrl('sources/my#photo.png'), equals('sources/my#photo.png'));

      String applyAlignment(String url, String alignment) {
        final base = cleanUrl(url);
        return alignment == 'center' ? base : '$base#$alignment';
      }

      // Switch left -> right -> center
      var url = 'sources/image.png';
      url = applyAlignment(url, 'left');
      expect(url, equals('sources/image.png#left'));

      url = applyAlignment(url, 'right');
      expect(url, equals('sources/image.png#right'));

      url = applyAlignment(url, 'center');
      expect(url, equals('sources/image.png'));
    });

    test('ReplaceNodeRequest preserves size and updates alignment cleanly in Document', () {
      final doc = MutableDocument(nodes: [
        ImageNode(
          id: 'img1',
          imageUrl: 'sources/diagram.png',
          expectedBitmapSize: const ExpectedSize(250, 150),
        ),
      ]);

      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: doc, composer: composer);

      // Simulate changing alignment to left
      final oldNode = doc.getNodeById('img1') as ImageNode;
      final clean = oldNode.imageUrl.replaceAll(RegExp(r'#(left|right|center)$'), '');
      final newUrl = '$clean#left';

      editor.execute([
        ReplaceNodeRequest(
          existingNodeId: oldNode.id,
          newNode: ImageNode(
            id: oldNode.id,
            imageUrl: newUrl,
            expectedBitmapSize: oldNode.expectedBitmapSize,
            metadata: {'textAlign': 'left'},
          ),
        ),
      ]);

      final updatedNode = doc.getNodeById('img1') as ImageNode;
      expect(updatedNode.imageUrl, equals('sources/diagram.png#left'));
      expect(updatedNode.expectedBitmapSize?.width, equals(250));
      expect(updatedNode.expectedBitmapSize?.height, equals(150));
      expect(updatedNode.metadata['textAlign'], equals('left'));

      final md = serializeDocumentToMarkdown(doc);
      expect(md, equals('![](sources/diagram.png#left =250x150)'));
    });
  });
}
