import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:super_editor/super_editor.dart';

/// A sleek desktop formatting toolbar styled with Forui components.
class ForuiEditorToolbar extends StatefulWidget {
  final Editor editor;
  final DocumentComposer composer;
  final CommonEditorOperations commonOps;
  final VoidCallback? onInsertImage;

  const ForuiEditorToolbar({
    super.key,
    required this.editor,
    required this.composer,
    required this.commonOps,
    this.onInsertImage,
  });

  @override
  State<ForuiEditorToolbar> createState() => _ForuiEditorToolbarState();
}

class _ForuiEditorToolbarState extends State<ForuiEditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.composer.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(ForuiEditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.composer != widget.composer) {
      oldWidget.composer.selectionNotifier.removeListener(_onSelectionChanged);
      widget.composer.selectionNotifier.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    widget.composer.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Document get _doc => widget.editor.context.document;
  CommonEditorOperations get _ops => widget.commonOps;

  bool _isAttributionActive(Attribution attribution) {
    final selection = widget.composer.selection;
    if (selection == null) return false;

    if (selection.isCollapsed) {
      return widget.composer.preferences.currentAttributions.contains(attribution);
    }
    return _doc.doesSelectedTextContainAttributions(selection, {attribution});
  }

  void _toggleAttribution(Attribution attribution) {
    final selection = widget.composer.selection;
    if (selection == null) return;

    if (selection.isCollapsed) {
      _ops.toggleComposerAttributions({attribution});
    } else {
      _ops.toggleAttributionsOnSelection({attribution});
    }
    setState(() {});
  }

  bool _isBlockType(Attribution blockType) {
    final selection = widget.composer.selection;
    if (selection == null) return false;
    final node = _doc.getNodeById(selection.extent.nodeId);
    if (node is ParagraphNode) {
      return node.getMetadataValue('blockType') == blockType;
    }
    return false;
  }

  void _toggleHeader(Attribution headerAttr) {
    final selection = widget.composer.selection;
    if (selection == null) return;
    final node = _doc.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return;

    if (node is ListItemNode) {
      _ops.convertToParagraph(newMetadata: {'blockType': headerAttr});
    } else if (node is ParagraphNode && node.getMetadataValue('blockType') == headerAttr) {
      _ops.convertToParagraph();
    } else {
      widget.editor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: node.id,
          blockType: headerAttr,
        ),
      ]);
    }
    setState(() {});
  }

  void _toggleBlockquote() {
    final selection = widget.composer.selection;
    if (selection == null) return;
    final node = _doc.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return;

    if (node is ParagraphNode && node.getMetadataValue('blockType') == blockquoteAttribution) {
      _ops.convertToParagraph();
    } else {
      _ops.convertToBlockquote(node.text);
    }
    setState(() {});
  }

  void _toggleList(ListItemType type) {
    final selection = widget.composer.selection;
    if (selection == null) return;
    final node = _doc.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return;

    if (node is ListItemNode && node.type == type) {
      _ops.convertToParagraph();
    } else {
      _ops.convertToListItem(type, node.text);
    }
    setState(() {});
  }

  void _toggleCodeBlock() {
    final selection = widget.composer.selection;
    if (selection == null) return;
    final node = _doc.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return;

    if (node is ParagraphNode && node.getMetadataValue('blockType') == codeAttribution) {
      _ops.convertToParagraph();
    } else {
      widget.editor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: node.id,
          blockType: codeAttribution,
        ),
      ]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final isBold = _isAttributionActive(boldAttribution);
    final isItalic = _isAttributionActive(italicsAttribution);
    final isUnderline = _isAttributionActive(underlineAttribution);
    final isStrike = _isAttributionActive(strikethroughAttribution);
    final isCode = _isAttributionActive(codeAttribution);

    final isH1 = _isBlockType(header1Attribution);
    final isH2 = _isBlockType(header2Attribution);
    final isH3 = _isBlockType(header3Attribution);
    final isQuote = _isBlockType(blockquoteAttribution);
    final isCodeBlock = _isBlockType(codeAttribution);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Text Formatting (Inline)
            _ToolbarButton(
              icon: FLucideIcons.bold,
              tooltip: 'Bold (Ctrl+B)',
              isActive: isBold,
              onPressed: () => _toggleAttribution(boldAttribution),
            ),
            _ToolbarButton(
              icon: FLucideIcons.italic,
              tooltip: 'Italic (Ctrl+I)',
              isActive: isItalic,
              onPressed: () => _toggleAttribution(italicsAttribution),
            ),
            _ToolbarButton(
              icon: FLucideIcons.underline,
              tooltip: 'Underline (Ctrl+U)',
              isActive: isUnderline,
              onPressed: () => _toggleAttribution(underlineAttribution),
            ),
            _ToolbarButton(
              icon: FLucideIcons.strikethrough,
              tooltip: 'Strikethrough (Ctrl+Shift+X)',
              isActive: isStrike,
              onPressed: () => _toggleAttribution(strikethroughAttribution),
            ),
            _ToolbarButton(
              icon: FLucideIcons.code,
              tooltip: 'Inline Code (Ctrl+` or Ctrl+E)',
              isActive: isCode,
              onPressed: () => _toggleAttribution(codeAttribution),
            ),

            _buildDivider(colors),

            // Headings
            _ToolbarTextButton(
              label: 'H1',
              tooltip: 'Heading 1 (Ctrl+Alt+1)',
              isActive: isH1,
              onPressed: () => _toggleHeader(header1Attribution),
            ),
            _ToolbarTextButton(
              label: 'H2',
              tooltip: 'Heading 2 (Ctrl+Alt+2)',
              isActive: isH2,
              onPressed: () => _toggleHeader(header2Attribution),
            ),
            _ToolbarTextButton(
              label: 'H3',
              tooltip: 'Heading 3 (Ctrl+Alt+3)',
              isActive: isH3,
              onPressed: () => _toggleHeader(header3Attribution),
            ),

            _buildDivider(colors),

            // Blocks & Lists
            _ToolbarButton(
              icon: FLucideIcons.list,
              tooltip: 'Bullet List (- )',
              isActive: false,
              onPressed: () => _toggleList(ListItemType.unordered),
            ),
            _ToolbarButton(
              icon: FLucideIcons.listOrdered,
              tooltip: 'Numbered List (1. )',
              isActive: false,
              onPressed: () => _toggleList(ListItemType.ordered),
            ),
            _ToolbarButton(
              icon: FLucideIcons.quote,
              tooltip: 'Quote Block (Ctrl+Shift+. or > )',
              isActive: isQuote,
              onPressed: _toggleBlockquote,
            ),
            _ToolbarButton(
              icon: FLucideIcons.fileCode,
              tooltip: 'Code Block (Ctrl+Alt+C or ``` )',
              isActive: isCodeBlock,
              onPressed: _toggleCodeBlock,
            ),

            if (widget.onInsertImage != null) ...[
              _buildDivider(colors),
              _ToolbarButton(
                icon: FLucideIcons.image,
                tooltip: 'Insert Image',
                isActive: false,
                onPressed: widget.onInsertImage,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(FColors colors) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: colors.border,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isActive ? colors.primary : colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ToolbarTextButton({
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? colors.primary : colors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
