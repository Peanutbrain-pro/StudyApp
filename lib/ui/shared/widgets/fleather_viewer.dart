import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart' hide Delta;

class FleatherViewer extends StatefulWidget {
  final Delta delta;
  const FleatherViewer({super.key, required this.delta});

  @override
  State<FleatherViewer> createState() => _FleatherViewerState();
}

class _FleatherViewerState extends State<FleatherViewer> {
  // late Delta _currentDelta;
  // bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    List<List<Operation>> paragraphs = _splitIntoParagraphs(widget.delta);

    return Column(
      mainAxisAlignment: .start,
      crossAxisAlignment: .stretch,
      // mainAxisSize: .min,
      children: paragraphs.map((paragraph) {
        final typography = context.theme.typography;

        if (paragraph.isEmpty) {
          return Text.rich(TextSpan(text: ' '));
        }

        // Set the Alignment of the block

        TextAlign paraAlignment = .left;
        // debugdebugPrint(paragraph.last.toString());
        final alignKey = ParchmentAttribute.alignment.center.key;
        if (paragraph.last.hasAttribute(alignKey)) {
          final alignValue = paragraph.last.attributes?[alignKey];
          if (alignValue == ParchmentAttribute.alignment.center.value) {
            paraAlignment = .center;
          } else if (alignValue == ParchmentAttribute.alignment.right.value) {
            paraAlignment = .right;
          } else if (alignValue == ParchmentAttribute.alignment.justify.value) {
            paraAlignment = .justify;
          }
        }

        // Set the Font Size of the block
        double? blockFontSize = typography.md.fontSize;
        final headerKey = ParchmentAttribute.h1.key;
        if (paragraph.last.hasAttribute(headerKey)) {
          final headerValue = paragraph.last.attributes?[headerKey];
          if (headerValue == ParchmentAttribute.h1.value) {
            blockFontSize = typography.xl4.fontSize;
          } else if (headerValue == ParchmentAttribute.h2.value) {
            blockFontSize = typography.xl2.fontSize;
          } else if (headerValue == ParchmentAttribute.h3.value) {
            blockFontSize = typography.xl.fontSize;
          } else if (headerValue == ParchmentAttribute.h4.value) {
            blockFontSize = typography.lg.fontSize;
          } else if (headerValue == ParchmentAttribute.h5.value) {
            blockFontSize = typography.lg.fontSize;
          } else if (headerValue == ParchmentAttribute.h6.value) {
            blockFontSize = typography.lg.fontSize;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text.rich(
            TextSpan(children: opsToTextSpan(paragraph)),
            textAlign: paraAlignment,
            style: .new(fontSize: blockFontSize),
          ),
        );
      }).toList(),
    );
  }

  List<List<Operation>> _splitIntoParagraphs(Delta delta) {
    final List<List<Operation>> paragraphs = [];
    List<Operation> currentParagraph = [];

    for (var op in delta.toList()) {
      if (op.data is String) {
        final text = op.data as String;
        final attrs = op.attributes;

        // Split text by newline, but keep the empty strings to detect \n
        final parts = text.split('\n');

        for (int i = 0; i < parts.length; i++) {
          currentParagraph.add(Operation.insert(parts[i], attrs));

          // If this isn't the last part, it means we hit a '\n'
          if (i < parts.length - 1) {
            // Only add if there's content, or add an empty op to preserve blank lines
            paragraphs.add(List.from(currentParagraph));
            currentParagraph.clear();
          }
        }
      }
    }

    // Add the final remaining bits
    if (currentParagraph.isNotEmpty &&
        currentParagraph.last.data is String &&
        (currentParagraph.last.data as String).isNotEmpty) {
      paragraphs.add(currentParagraph);
    }

    return paragraphs;
  }

  List<InlineSpan> opsToTextSpan(List<Operation> paragraph) {
    final List<InlineSpan> spans = [];

    // get the indentation level
    final lastStyle = ParchmentStyle.fromJson(paragraph.last.attributes);
    final indentation = lastStyle.get(ParchmentAttribute.indent);
    // debugdebugPrint("${indentation?.value}");
    if (indentation != null) {
      spans.add(WidgetSpan(child: SizedBox(width: 24 * (indentation.value ?? 1).toDouble())));
    }
    if (lastStyle.contains(ParchmentAttribute.ul)) {
      spans.add(
        WidgetSpan(
          child: Padding(padding: const EdgeInsets.only(left: 5, right: 10), child: Text("•")),
        ),
      );
    }

    for (Operation op in paragraph) {
      // debugdebugPrint(op.data.toString());
      // if ((op.data as String).isEmpty) debugdebugPrint("Empty part");
      if ((op.data as String).isNotEmpty) {
        spans.add(
          TextSpan(
            text: op.data as String,
            style: TextStyle(
              height: 1.2,
              fontWeight: op.hasAttribute(ParchmentAttribute.bold.key) ? .bold : null,
              fontStyle: op.hasAttribute(ParchmentAttribute.italic.key) ? .italic : null,
              decoration: op.hasAttribute(ParchmentAttribute.underline.key) ? .underline : null,
            ),
          ),
        );
      }
    }
    return spans;
  }
}

// double? _getHeadingFontSize (Operation op, FTypography typography) {
//   if (op.hasAttribute(ParchmentAttribute.heading.level1.key)) return typography.xl8.fontSize;
//   if (op.hasAttribute(ParchmentAttribute.heading.level2.key)) return typography.xl6.fontSize;
//   if (op.hasAttribute(ParchmentAttribute.heading.level3.key)) return typography.xl4.fontSize;
//   return null;
// }
