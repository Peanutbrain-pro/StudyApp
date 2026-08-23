import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/ui/shared/widgets/markdown_webview_editor.dart';

class MarkdownToolbar extends StatefulWidget {
  final MarkdownEditorController controller;

  const MarkdownToolbar({super.key, required this.controller});

  @override
  State<MarkdownToolbar> createState() => _MarkdownToolbarState();
}

class _MarkdownToolbarState extends State<MarkdownToolbar> {
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _latexController = TextEditingController();

  @override
  void dispose() {
    _imageUrlController.dispose();
    _latexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Headings
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n\n# Heading 1\n');
              },
              child: const Text('H1', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n\n## Heading 2\n');
              },
              child: const Text('H2', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n\n### Heading 3\n');
              },
              child: const Text('H3', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const VerticalDivider(indent: 8, endIndent: 8),

            // Text Styles
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md **bold text** ');
              },
              child: const Icon(Icons.format_bold, size: 18),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md *italic text* ');
              },
              child: const Icon(Icons.format_italic, size: 18),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md `inline code` ');
              },
              child: const Icon(Icons.code, size: 18),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n> Blockquote text\n');
              },
              child: const Icon(Icons.format_quote, size: 18),
            ),
            const VerticalDivider(indent: 8, endIndent: 8),

            // Lists
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n- Bullet item\n- Bullet item 2\n');
              },
              child: const Icon(Icons.format_list_bulleted, size: 18),
            ),
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () {
                final md = widget.controller.markdown;
                widget.controller.setMarkdown('$md\n1. Numbered item\n2. Numbered item 2\n');
              },
              child: const Icon(Icons.format_list_numbered, size: 18),
            ),
            const VerticalDivider(indent: 8, endIndent: 8),

            // LaTeX Math Button
            FPopover(
              offset: const Offset(0, 8),
              popoverBuilder: (context, popoverController) {
                return Container(
                  width: 320,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insert LaTeX Formula', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _latexController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. \\int_{-\\infty}^{\\infty} f(x) dx',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FButton(
                            size: .sm,
                            variant: .outline,
                            onPress: popoverController.hide,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FButton(
                            size: .sm,
                            onPress: () {
                              final text = _latexController.text.trim();
                              if (text.isNotEmpty) {
                                final md = widget.controller.markdown;
                                widget.controller.setMarkdown('$md\n\n\$\$\n$text\n\$\$\n\n');
                                _latexController.clear();
                                popoverController.hide();
                              }
                            },
                            child: const Text('Insert Math'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              builder: (context, popoverController, child) {
                return FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: popoverController.toggle,
                  child: const Icon(Icons.functions, size: 18),
                );
              },
            ),

            const VerticalDivider(indent: 8, endIndent: 8),

            // Custom Image Embed Button
            FPopover(
              offset: const Offset(0, 8),
              popoverBuilder: (context, popoverController) {
                return Container(
                  width: 340,
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
                      const Text('Insert Image Embed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 12),
                      FButton(
                        size: .md,
                        variant: .outline,
                        onPress: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'],
                          );
                          if (result != null && result.files.isNotEmpty) {
                            final path = result.files.single.path;
                            final name = result.files.single.name;
                            if (path != null) {
                              widget.controller.insertImage(
                                url: path.replaceAll(r'\', '/'),
                                isNetwork: false,
                                filename: name,
                              );
                              popoverController.hide();
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FIcons.imagePlus, size: 18),
                            SizedBox(width: 8),
                            Text('Pick from Computer'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Or insert Image URL:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          hintText: 'https://images.unsplash.com/...',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (url) {
                          if (url.trim().isNotEmpty) {
                            widget.controller.insertImage(
                              url: url.trim(),
                              isNetwork: true,
                              filename: 'Image',
                            );
                            _imageUrlController.clear();
                            popoverController.hide();
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FButton(
                          size: .sm,
                          onPress: () {
                            final url = _imageUrlController.text.trim();
                            if (url.isNotEmpty) {
                              widget.controller.insertImage(
                                url: url,
                                isNetwork: true,
                                filename: 'Image',
                              );
                              _imageUrlController.clear();
                              popoverController.hide();
                            }
                          },
                          child: const Text('Insert URL'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              builder: (context, popoverController, child) {
                return FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: popoverController.toggle,
                  child: const Icon(FIcons.image, size: 18),
                );
              },
            ),

            // Custom Source Embed Button (PDF / Documents / Links)
            FButton.icon(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                final result = await FilePicker.pickFiles(
                  type: FileType.any,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.single;
                  final path = file.path;
                  if (path != null) {
                    final filename = file.name;
                    final extension = file.extension ?? 'file';
                    widget.controller.insertSource(
                      filename: filename,
                      filetype: extension,
                      url: path.replaceAll(r'\', '/'),
                    );
                  }
                }
              },
              child: const Icon(FIcons.squareArrowOutUpRight, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
