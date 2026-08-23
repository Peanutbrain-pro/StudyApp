import 'package:fleather/fleather.dart';
import 'package:material_ui/material_ui.dart';
// import 'package:forui/forui.dart' hide Delta;

class FleatherViewer extends StatefulWidget {
  final Delta delta;

  const FleatherViewer({super.key, required this.delta});

  @override
  State<FleatherViewer> createState() => _FleatherViewerState();
}

class _FleatherViewerState extends State<FleatherViewer> {
  late final FleatherController controller;

  @override
  void initState() {
    super.initState();
    controller = .new(document: .fromDelta(widget.delta));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // late Delta _currentDelta;
  // bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 12),
      child: FleatherEditor(controller: controller, readOnly: true, showCursor: false),
    );

    // final colors = context.theme.colors;
    // final typography = context.theme.typography;
    // final List<List<Operation>> paragraphs = _splitIntoParagraphs(widget.delta);

    // return Padding(
    //   padding: const EdgeInsets.all(12.0),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     // spacing: 17,
    //     children: paragraphs
    //         .asMap()
    //         .entries
    //         .map((entry) {
    //           final index = entry.key;
    //           final paragraph = entry.value;
    //           bool isHeader = false;

    //           // double? blockFontSize = typography.md.fontSize;
    //           TextStyle textStyle = typography.md;
    //           TextAlign paraAlignment = TextAlign.left;

    //           if (paragraph.isEmpty) {
    //             return const Text.rich(
    //               TextSpan(text: '\u200b\n'),
    //               // style: textStyle,
    //               // strutStyle: .new(fontSize: blockFontSize, height: typography.md.height),
    //             );
    //           }

    //           // Set the Alignment of the block
    //           final alignKey = ParchmentAttribute.alignment.center.key;
    //           if (paragraph.last.hasAttribute(alignKey)) {
    //             final alignValue = paragraph.last.attributes?[alignKey];
    //             if (alignValue == ParchmentAttribute.alignment.center.value) {
    //               paraAlignment = TextAlign.center;
    //             } else if (alignValue == ParchmentAttribute.alignment.right.value) {
    //               paraAlignment = TextAlign.right;
    //             } else if (alignValue == ParchmentAttribute.alignment.justify.value) {
    //               paraAlignment = TextAlign.justify;
    //             }
    //           }

    //           // Set the Font Size of the block
    //           Color? textColor;
    //           TextDecoration? decor;
    //           final headerKey = ParchmentAttribute.h1.key;
    //           if (paragraph.last.hasAttribute(headerKey)) {
    //             isHeader = true;
    //             final headerValue = paragraph.last.attributes?[headerKey];
    //             if (headerValue == ParchmentAttribute.h1.value) {
    //               // blockFontSize = typography.xl4.fontSize;
    //               textStyle = typography.xl4;
    //               textColor = colors.foreground.withAlpha(160);
    //             } else if (headerValue == ParchmentAttribute.h2.value) {
    //               // blockFontSize = typography.xl2.fontSize;
    //               textStyle = typography.xl2;
    //               textColor = colors.foreground.withAlpha(160);
    //             } else if (headerValue == ParchmentAttribute.h3.value) {
    //               // blockFontSize = typography.xl.fontSize;
    //               textStyle = typography.xl;
    //               textColor = colors.foreground.withAlpha(160);
    //             } else if (headerValue == ParchmentAttribute.h4.value) {
    //               // blockFontSize = typography.lg.fontSize;
    //               textStyle = typography.lg;
    //               textColor = colors.foreground.withAlpha(120);
    //             } else if (headerValue == ParchmentAttribute.h5.value) {
    //               decor = TextDecoration.underline;
    //               textColor = colors.foreground.withAlpha(160);
    //             } else if (headerValue == ParchmentAttribute.h6.value) {
    //               // blockFontSize = typography.md.fontSize;
    //               textColor = colors.foreground.withAlpha(120);
    //             }
    //           }

    //           return Padding(
    //             padding: .zero,
    //             // padding: EdgeInsets.only(
    //             //   bottom: (index != paragraphs.length - 1)
    //             //       ? (isHeader)
    //             //             ? 10
    //             //             : 17
    //             //       : 0,
    //             // ),
    //             child: Text.rich(
    //               TextSpan(
    //                 children: [
    //                   ...opsToTextSpan(paragraph),
    //                   const TextSpan(
    //                     text: '\n',
    //                     // style: .new(height: 0.1, fontSize: 0.1)
    //                   ),
    //                 ],
    //               ),
    //               textAlign: paraAlignment,
    //               style: TextStyle(fontSize: textStyle.fontSize, decoration: decor, color: textColor),
    //               // strutStyle: .new(height: textStyle.height, fontSize: textStyle.fontSize),
    //             ),
    //           );
    //         })
    //         .toList(growable: false),
    //   ),
    // );
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
        const WidgetSpan(
          child: Padding(padding: EdgeInsets.only(left: 5, right: 10), child: Text("•")),
        ),
      );
    }

    for (Operation op in paragraph) {
      // debugdebugPrint(op.data.toString());
      // if ((op.data as String).isEmpty) debugdebugPrint("Empty part");
      // if ((op.data as String).isNotEmpty) {
      spans.add(
        TextSpan(
          text: op.data as String,
          style: TextStyle(
            // height: 1,
            fontWeight: op.hasAttribute(ParchmentAttribute.bold.key) ? .bold : null,
            fontStyle: op.hasAttribute(ParchmentAttribute.italic.key) ? .italic : null,
            decoration: op.hasAttribute(ParchmentAttribute.underline.key) ? .underline : null,
          ),
        ),
      );
      // }
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
