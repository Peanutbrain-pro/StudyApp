import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:super_editor/super_editor.dart';

/// Builds a [Stylesheet] customized with Forui colors and typography.
Stylesheet createForuiEditorStylesheet({
  required BuildContext context,
  String? fontFamily,
}) {
  final colors = context.theme.colors;
  final effectiveFontFamily = (fontFamily != null && fontFamily != 'System Default' && fontFamily.isNotEmpty)
      ? fontFamily
      : null;

  return Stylesheet(
    documentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    rules: [
      // Base / all nodes default
      StyleRule(
        BlockSelector.all,
        (doc, docNode) {
          return {
            Styles.maxWidth: double.infinity,
            Styles.padding: const CascadingPadding.symmetric(horizontal: 0),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: effectiveFontFamily,
              fontSize: 15,
              height: 1.6,
            ),
          };
        },
      ),

      // Paragraph spacing
      StyleRule(
        const BlockSelector("paragraph"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 10),
          };
        },
      ),

      // Header 1 (#)
      StyleRule(
        const BlockSelector("header1"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 28, bottom: 8),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: effectiveFontFamily,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          };
        },
      ),

      // Header 2 (##)
      StyleRule(
        const BlockSelector("header2"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 22, bottom: 6),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: effectiveFontFamily,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          };
        },
      ),

      // Header 3 (###)
      StyleRule(
        const BlockSelector("header3"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 18, bottom: 4),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: effectiveFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          };
        },
      ),

      // Blockquote (>)
      StyleRule(
        const BlockSelector("blockquote"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 12, bottom: 4),
            Styles.textStyle: TextStyle(
              color: colors.mutedForeground,
              fontFamily: effectiveFontFamily,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          };
        },
      ),

      // Code block (```)
      StyleRule(
        const BlockSelector("code"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 12, bottom: 6),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: 'JetBrains Mono',
              fontSize: 13.5,
              height: 1.5,
            ),
          };
        },
      ),

      // List Items (- or 1.)
      StyleRule(
        const BlockSelector("listItem"),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(top: 6),
            Styles.textStyle: TextStyle(
              color: colors.foreground,
              fontFamily: effectiveFontFamily,
              fontSize: 15,
              height: 1.5,
            ),
          };
        },
      ),

      // Bottom padding for final block
      StyleRule(
        BlockSelector.all.last(),
        (doc, docNode) {
          return {
            Styles.padding: const CascadingPadding.only(bottom: 64),
          };
        },
      ),
    ],
    inlineTextStyler: (attributions, existingStyle) {
      var newStyle = existingStyle;

      for (final attribution in attributions) {
        if (attribution == boldAttribution) {
          newStyle = newStyle.copyWith(fontWeight: FontWeight.bold);
        } else if (attribution == italicsAttribution) {
          newStyle = newStyle.copyWith(fontStyle: FontStyle.italic);
        } else if (attribution == underlineAttribution) {
          newStyle = newStyle.copyWith(
            decoration: newStyle.decoration == null
                ? TextDecoration.underline
                : TextDecoration.combine([TextDecoration.underline, newStyle.decoration!]),
          );
        } else if (attribution == strikethroughAttribution) {
          newStyle = newStyle.copyWith(
            decoration: newStyle.decoration == null
                ? TextDecoration.lineThrough
                : TextDecoration.combine([TextDecoration.lineThrough, newStyle.decoration!]),
          );
        } else if (attribution == codeAttribution) {
          newStyle = newStyle.copyWith(
            fontFamily: 'JetBrains Mono',
            backgroundColor: colors.primary.withValues(alpha: 0.1),
            color: colors.primary,
            fontSize: (newStyle.fontSize ?? 15) * 0.9,
          );
        } else if (attribution is LinkAttribution) {
          newStyle = newStyle.copyWith(
            color: colors.primary,
            decoration: TextDecoration.underline,
          );
        }
      }

      return newStyle;
    },
  );
}

/// Selection styles that use Forui's primary theme color.
SelectionStyles createForuiSelectionStyles(BuildContext context) {
  final colors = context.theme.colors;
  return SelectionStyles(
    selectionColor: colors.primary.withValues(alpha: 0.25),
  );
}

/// Document overlay builders that theme the blinking caret and handles to match Forui colors,
/// while suppressing the caret entirely on non-text block nodes (such as images).
List<SuperEditorLayerBuilder> createForuiDocumentOverlayBuilders(BuildContext context) {
  final colors = context.theme.colors;
  return [
    const SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
    const SuperEditorIosHandlesDocumentLayerBuilder(),
    const SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
    const SuperEditorAndroidHandlesDocumentLayerBuilder(),
    ForuiCaretOverlayBuilder(
      caretStyle: CaretStyle(
        width: 2,
        color: colors.foreground,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  ];
}

/// A [SuperEditorLayerBuilder] that paints a theme-aware caret for text nodes,
/// but suppresses the caret for block/binary nodes like [ImageNode].
class ForuiCaretOverlayBuilder implements SuperEditorLayerBuilder {
  const ForuiCaretOverlayBuilder({
    this.caretStyle = const CaretStyle(
      width: 2,
      color: Colors.black,
    ),
    this.platformOverride,
    this.displayOnAllPlatforms = false,
    this.displayCaretWithExpandedSelection = true,
    this.blinkTimingMode = BlinkTimingMode.timer,
  });

  final CaretStyle caretStyle;
  final TargetPlatform? platformOverride;
  final bool displayOnAllPlatforms;
  final bool displayCaretWithExpandedSelection;
  final BlinkTimingMode blinkTimingMode;

  @override
  ContentLayerWidget build(BuildContext context, SuperEditorContext editContext) {
    return ForuiCaretDocumentOverlay(
      composer: editContext.composer,
      documentLayoutResolver: () => editContext.documentLayout,
      caretStyle: caretStyle,
      platformOverride: platformOverride,
      displayOnAllPlatforms: displayOnAllPlatforms,
      displayCaretWithExpandedSelection: displayCaretWithExpandedSelection,
      blinkTimingMode: blinkTimingMode,
    );
  }
}

/// A [CaretDocumentOverlay] that does not paint a caret on [UpstreamDownstreamNodePosition]s (images).
class ForuiCaretDocumentOverlay extends CaretDocumentOverlay {
  const ForuiCaretDocumentOverlay({
    super.key,
    required super.composer,
    required super.documentLayoutResolver,
    super.caretStyle,
    super.platformOverride,
    super.displayOnAllPlatforms,
    super.displayCaretWithExpandedSelection,
    super.blinkTimingMode,
  });

  @override
  DocumentLayoutLayerState<CaretDocumentOverlay, Rect?> createState() => _ForuiCaretDocumentOverlayState();
}

// ignore: invalid_use_of_visible_for_testing_member
class _ForuiCaretDocumentOverlayState extends CaretDocumentOverlayState {
  @override
  Rect? computeLayoutDataWithDocumentLayout(
      BuildContext contentLayersContext, BuildContext documentContext, DocumentLayout documentLayout) {
    final documentSelection = widget.composer.selection;
    if (documentSelection == null) {
      return null;
    }

    // Suppress caret on non-text block nodes (such as ImageNode)
    if (documentSelection.extent.nodePosition is UpstreamDownstreamNodePosition ||
        documentSelection.base.nodePosition is UpstreamDownstreamNodePosition) {
      return null;
    }

    return super.computeLayoutDataWithDocumentLayout(contentLayersContext, documentContext, documentLayout);
  }
}
