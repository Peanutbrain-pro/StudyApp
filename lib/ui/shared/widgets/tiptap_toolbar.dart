import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/ui/shared/widgets/tiptap_editor.dart';

class TipTapToolbar extends StatefulWidget {
  final TipTapEditorController controller;

  const TipTapToolbar({super.key, required this.controller});

  @override
  State<TipTapToolbar> createState() => _TipTapToolbarState();
}

class _TipTapToolbarState extends State<TipTapToolbar> {
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.selectionState;

        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tip('Undo (Ctrl+Z)',
                    FButton.icon(
                      variant: .ghost,
                      size: .sm,
                      onPress: state.canUndo ? () => widget.controller.undo() : null,
                      child: const Icon(FLucideIcons.undo, size: 16),
                    )),
                _tip('Redo (Ctrl+Y)',
                    FButton.icon(
                      variant: .ghost,
                      size: .sm,
                      onPress: state.canRedo ? () => widget.controller.redo() : null,
                      child: const Icon(FLucideIcons.redo, size: 16),
                    )),
                const VerticalDivider(indent: 10, endIndent: 10),

                _tip('Heading 1', _fmt(state.isHeading1, () => widget.controller.toggleHeading(1),
                    const Text('H1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
                _tip('Heading 2', _fmt(state.isHeading2, () => widget.controller.toggleHeading(2),
                    const Text('H2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
                _tip('Heading 3', _fmt(state.isHeading3, () => widget.controller.toggleHeading(3),
                    const Text('H3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
                const VerticalDivider(indent: 10, endIndent: 10),

                _tip('Bold (Ctrl+B)', _fmt(state.isBold, widget.controller.toggleBold, const Icon(Icons.format_bold, size: 17))),
                _tip('Italic (Ctrl+I)', _fmt(state.isItalic, widget.controller.toggleItalic, const Icon(Icons.format_italic, size: 17))),
                _tip('Underline (Ctrl+U)', _fmt(state.isUnderline, widget.controller.toggleUnderline, const Icon(Icons.format_underlined, size: 17))),
                _tip('Strikethrough', _fmt(state.isStrike, widget.controller.toggleStrike, const Icon(Icons.strikethrough_s, size: 17))),
                _tip('Highlight', _fmt(state.isHighlight, widget.controller.toggleHighlight, const Icon(Icons.highlight_alt, size: 17))),
                _tip('Inline Code', _fmt(state.isCode, widget.controller.toggleCode, const Icon(Icons.code, size: 17))),
                _tip('Quote', _fmt(state.isBlockquote, widget.controller.toggleBlockquote, const Icon(Icons.format_quote, size: 17))),
                const VerticalDivider(indent: 10, endIndent: 10),

                _tip('Bullet List', _fmt(state.isBulletList, widget.controller.toggleBulletList, const Icon(Icons.format_list_bulleted, size: 17))),
                _tip('Numbered List', _fmt(state.isOrderedList, widget.controller.toggleOrderedList, const Icon(Icons.format_list_numbered, size: 17))),
                _tip('Checklist', _fmt(state.isTaskList, widget.controller.toggleTaskList, const Icon(Icons.check_box_outlined, size: 17))),
                _tip('Code Block', _fmt(state.isCodeBlock, widget.controller.toggleCodeBlock, const Icon(FLucideIcons.codeXml, size: 17))),
                const VerticalDivider(indent: 10, endIndent: 10),

                // Source pill opens a modal inside the editor WebView
                _tip('Insert Source Reference',
                    FButton.icon(
                      variant: .ghost,
                      size: .sm,
                      onPress: () => widget.controller.openSourceModal(),
                      child: const Icon(FLucideIcons.bookmark, size: 17),
                    )),

                // Math — opens prompt inside WebView
                _tip('Insert Math Formula',
                    FButton.icon(
                      variant: .ghost,
                      size: .sm,
                      onPress: () => widget.controller.showMathModal(),
                      child: const Icon(Icons.functions, size: 17),
                    )),
                const VerticalDivider(indent: 10, endIndent: 10),

                // Image
                _buildImageButton(colors),

                // Divider
                _tip('Divider',
                    FButton.icon(
                      variant: .ghost,
                      size: .sm,
                      onPress: () => widget.controller.insertHorizontalRule(),
                      child: const Icon(Icons.horizontal_rule, size: 17),
                    )),

                // Table — click inserts, right-click inside table cell for row/col options
                _tip('Insert Table  (right-click inside table for row/col options)',
                    FButton.icon(
                      variant: state.isTable ? .secondary : .ghost,
                      size: .sm,
                      onPress: () => widget.controller.insertTable(rows: 3, cols: 3),
                      child: const Icon(FLucideIcons.table, size: 17),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tip(String msg, Widget child) {
    return Tooltip(message: msg, waitDuration: const Duration(milliseconds: 500), child: child);
  }

  Widget _fmt(bool active, VoidCallback onPress, Widget child) {
    return FButton.icon(
      variant: active ? .secondary : .ghost,
      size: .sm,
      onPress: onPress,
      child: child,
    );
  }

  Widget _buildImageButton(FColors colors) {
    return _tip('Insert Image',
      FPopover(
        offset: const Offset(0, 8),
        popoverBuilder: (context, ctrl) {
          return Container(
            width: 300,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Insert Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                FButton(
                  size: .md,
                  variant: .outline,
                  onPress: () async {
                    final result = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'],
                    );
                    if (result != null && result.path != null) {
                      widget.controller.insertImage(
                        url: result.path!.replaceAll(r'\\', '/'),
                        isNetwork: false,
                        filename: result.name,
                      );
                      ctrl.hide();
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FLucideIcons.imagePlus, size: 18),
                      SizedBox(width: 8),
                      Text('Pick from Computer'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Or URL:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://...',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (url) {
                    if (url.trim().isNotEmpty) {
                      widget.controller.insertImage(url: url.trim(), isNetwork: true, filename: 'Image');
                      _imageUrlController.clear();
                      ctrl.hide();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FButton(
                    size: .sm,
                    onPress: () {
                      final url = _imageUrlController.text.trim();
                      if (url.isNotEmpty) {
                        widget.controller.insertImage(url: url, isNetwork: true, filename: 'Image');
                        _imageUrlController.clear();
                        ctrl.hide();
                      }
                    },
                    child: const Text('Insert'),
                  ),
                ),
              ],
            ),
          );
        },
        builder: (context, ctrl, _) => FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: ctrl.toggle,
          child: const Icon(FLucideIcons.image, size: 17),
        ),
      ),
    );
  }
}
