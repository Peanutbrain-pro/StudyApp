import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as p;
import 'package:super_editor/super_editor.dart';

import 'editor_shortcuts.dart';
import 'editor_theme.dart';
import 'editor_toolbar.dart';
import 'resizable_image.dart';

/// A native Flutter rich text document editor screen using [SuperEditor].
class SuperEditorNoteScreen extends StatefulWidget {
  final int notebookId;
  final String noteFilePath;
  final String sourcesDirectoryPath;
  final String? fontFamily;
  final ValueChanged<String>? onContentChanged;

  const SuperEditorNoteScreen({
    super.key,
    required this.notebookId,
    required this.noteFilePath,
    required this.sourcesDirectoryPath,
    this.fontFamily,
    this.onContentChanged,
  });

  @override
  State<SuperEditorNoteScreen> createState() => _SuperEditorNoteScreenState();
}

class _SuperEditorNoteScreenState extends State<SuperEditorNoteScreen> {
  final _documentLayoutKey = GlobalKey();
  MutableDocument? _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  late CommonEditorOperations _commonOps;
  bool _isLoading = true;
  Timer? _debounceSaveTimer;
  String _lastSavedMarkdown = '';

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  void didUpdateWidget(SuperEditorNoteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteFilePath != widget.noteFilePath) {
      _debounceSaveTimer?.cancel();
      _saveCurrentDocumentSync();
      _loadDocument();
    }
  }

  @override
  void dispose() {
    _debounceSaveTimer?.cancel();
    _saveCurrentDocumentSync();
    if (_document != null) {
      _document!.removeListener(_onDocumentChanged);
    }
    _editor.dispose();
    _composer.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    setState(() => _isLoading = true);

    String markdownContent = '';
    if (widget.noteFilePath.isNotEmpty) {
      final file = File(widget.noteFilePath);
      if (await file.exists()) {
        try {
          markdownContent = await file.readAsString();
        } catch (e) {
          debugPrint('Error reading note markdown file: $e');
        }
      }
    }

    _lastSavedMarkdown = markdownContent;

    // Parse markdown to MutableDocument
    MutableDocument doc;
    if (markdownContent.trim().isEmpty) {
      doc = MutableDocument(
        nodes: [
          ParagraphNode(
            id: Editor.createNodeId(),
            text: AttributedText(),
          ),
        ],
      );
    } else {
      try {
        doc = deserializeMarkdownToDocument(markdownContent);
        if (doc.isEmpty) {
          doc = MutableDocument(
            nodes: [
              ParagraphNode(
                id: Editor.createNodeId(),
                text: AttributedText(),
              ),
            ],
          );
        } else {
          // Restore image alignment from URL hash fragments if present
          for (final node in doc) {
            if (node is ImageNode) {
              if (node.imageUrl.endsWith('#left')) {
                node.metadata['textAlign'] = 'left';
              } else if (node.imageUrl.endsWith('#right')) {
                node.metadata['textAlign'] = 'right';
              } else {
                node.metadata['textAlign'] = 'center';
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error deserializing markdown: $e. Falling back to plain text.');
        doc = MutableDocument(
          nodes: [
            ParagraphNode(
              id: Editor.createNodeId(),
              text: AttributedText(markdownContent),
            ),
          ],
        );
      }
    }

    // Ensure document never ends on a non-text block (such as an image)
    if (doc.isNotEmpty && doc.last is! TextNode) {
      doc.insertNodeAt(
        doc.nodeCount,
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(),
        ),
      );
    }

    _document = doc;
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document!,
      composer: _composer,
      isHistoryEnabled: true,
    );
    _editor.reactionPipeline.add(const CodeBlockConversionReaction());
    _editor.reactionPipeline.add(const EnsureTrailingParagraphReaction());
    _commonOps = CommonEditorOperations(
      editor: _editor,
      document: _document!,
      composer: _composer,
      documentLayoutResolver: () => _documentLayoutKey.currentState as DocumentLayout,
    );

    // Listen for changes to auto-save with debounce
    _document!.addListener(_onDocumentChanged);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onDocumentChanged(DocumentChangeLog changeLog) {
    _debounceSaveTimer?.cancel();
    _debounceSaveTimer = Timer(const Duration(milliseconds: 750), _triggerSave);
  }

  void _triggerSave() {
    if (_document == null) return;

    try {
      final markdown = serializeDocumentToMarkdown(_document!);
      if (markdown != _lastSavedMarkdown) {
        _lastSavedMarkdown = markdown;
        _saveMarkdownToFile(markdown);
        widget.onContentChanged?.call(markdown);
      }
    } catch (e) {
      debugPrint('Error serializing document to markdown: $e');
    }
  }

  void _saveMarkdownToFile(String markdown) async {
    if (widget.noteFilePath.isEmpty) return;

    try {
      final file = File(widget.noteFilePath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString(markdown);
    } catch (e) {
      debugPrint('Error writing markdown note file: $e');
    }
  }

  void _saveCurrentDocumentSync() {
    if (_document == null || widget.noteFilePath.isEmpty) return;

    try {
      final markdown = serializeDocumentToMarkdown(_document!);
      final file = File(widget.noteFilePath);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(markdown);
    } catch (e) {
      debugPrint('Error sync-saving markdown note file: $e');
    }
  }

  void _handleResizeImage(String nodeId, int? width, int? height) {
    if (_document == null) return;
    final oldNode = _document!.getNodeById(nodeId);
    if (oldNode is! ImageNode) return;

    final newNode = ImageNode(
      id: oldNode.id,
      imageUrl: oldNode.imageUrl,
      altText: oldNode.altText,
      expectedBitmapSize: width != null ? ExpectedSize(width, height) : null,
      metadata: Map<String, dynamic>.from(oldNode.metadata),
    );

    _editor.execute([
      ReplaceNodeRequest(
        existingNodeId: oldNode.id,
        newNode: newNode,
      ),
    ]);
  }

  void _handleAlignmentChanged(String nodeId, String alignment) {
    if (_document == null) return;
    final oldNode = _document!.getNodeById(nodeId);
    if (oldNode is! ImageNode) return;

    final cleanUrl = oldNode.imageUrl.split('#').first;
    final newUrl = alignment == 'center' ? cleanUrl : '$cleanUrl#$alignment';

    final updatedMetadata = Map<String, dynamic>.from(oldNode.metadata);
    updatedMetadata['textAlign'] = alignment;

    final newNode = ImageNode(
      id: oldNode.id,
      imageUrl: newUrl,
      altText: oldNode.altText,
      expectedBitmapSize: oldNode.expectedBitmapSize,
      metadata: updatedMetadata,
    );

    _editor.execute([
      ReplaceNodeRequest(
        existingNodeId: oldNode.id,
        newNode: newNode,
      ),
    ]);
  }

  void _selectImageNode(String nodeId) {
    _editor.execute([
      ChangeSelectionRequest(
        DocumentSelection(
          base: DocumentPosition(
            nodeId: nodeId,
            nodePosition: const UpstreamDownstreamNodePosition.upstream(),
          ),
          extent: DocumentPosition(
            nodeId: nodeId,
            nodePosition: const UpstreamDownstreamNodePosition.downstream(),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.userInteraction,
      ),
    ]);
  }

  void _deselectNode() {
    _editor.execute([
      const ClearSelectionRequest(),
    ]);
  }

  void _handleDeleteImage(String nodeId) {
    if (_document == null) return;
    if (_document!.nodeCount <= 1) {
      _editor.execute([
        ReplaceNodeWithEmptyParagraphWithCaretRequest(nodeId: nodeId),
      ]);
    } else {
      _editor.execute([
        DeleteNodeRequest(nodeId: nodeId),
      ]);
    }
  }

  ExecutionInstruction _preventTypingOnImageNode({
    required SuperEditorContext editContext,
    required KeyEvent keyEvent,
  }) {
    final selection = editContext.composer.selection;
    if (selection == null) {
      return ExecutionInstruction.continueExecution;
    }

    final extentNode = editContext.document.getNodeById(selection.extent.nodeId);
    final baseNode = editContext.document.getNodeById(selection.base.nodeId);
    final isImageSelected = extentNode is ImageNode || baseNode is ImageNode;

    if (!isImageSelected) {
      return ExecutionInstruction.continueExecution;
    }

    // Allow Delete and Backspace to delete the selected image
    if (keyEvent.logicalKey == LogicalKeyboardKey.delete ||
        keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
      return ExecutionInstruction.continueExecution;
    }

    // Allow keyboard shortcuts like Ctrl+Z, Ctrl+Shift+Z, Ctrl+C, etc.
    if (keyEvent.isPrimaryShortcutKeyPressed) {
      return ExecutionInstruction.continueExecution;
    }

    // Escape or Tab
    if (keyEvent.logicalKey == LogicalKeyboardKey.escape ||
        keyEvent.logicalKey == LogicalKeyboardKey.tab) {
      return ExecutionInstruction.continueExecution;
    }

    final imageNode = (extentNode is ImageNode ? extentNode : baseNode!) as ImageNode;

    // Arrow Down: Navigate to the node below, or create an empty paragraph below
    if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
      _handleTapEmptySpaceAroundImage(imageNode.id, false);
      return ExecutionInstruction.haltExecution;
    }

    // Arrow Up: Navigate to the node above, or create an empty paragraph above
    if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
      _handleTapEmptySpaceAroundImage(imageNode.id, true);
      return ExecutionInstruction.haltExecution;
    }

    // Arrow Right: Move to next node or create one
    if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight) {
      _handleTapEmptySpaceAroundImage(imageNode.id, false);
      return ExecutionInstruction.haltExecution;
    }

    // Arrow Left: Move to previous node or create one
    if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _handleTapEmptySpaceAroundImage(imageNode.id, true);
      return ExecutionInstruction.haltExecution;
    }

    // Pressing Enter while an image is selected inserts a new empty paragraph right after the image
    if (keyEvent is KeyDownEvent &&
        (keyEvent.logicalKey == LogicalKeyboardKey.enter ||
            keyEvent.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      _handleTapEmptySpaceAroundImage(imageNode.id, false);
      return ExecutionInstruction.haltExecution;
    }

    // Block any printable character typing from modifying or overwriting the image
    if (keyEvent.character != null && keyEvent.character!.isNotEmpty) {
      return ExecutionInstruction.haltExecution;
    }

    return ExecutionInstruction.continueExecution;
  }

  void _handleTapEmptySpaceAroundImage(String nodeId, bool isBefore) {
    if (_document == null) return;
    final nodeIndex = _document!.getNodeIndexById(nodeId);
    if (nodeIndex == -1) return;

    if (isBefore) {
      if (nodeIndex > 0) {
        final prevNode = _document!.getNodeAt(nodeIndex - 1);
        if (prevNode is TextNode) {
          _placeCaretAtEndOfTextNode(prevNode.id);
          return;
        }
      }
      final newParagraph = ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(),
      );
      _editor.execute([
        InsertNodeBeforeNodeRequest(
          existingNodeId: nodeId,
          newNode: newParagraph,
        ),
        ChangeSelectionRequest(
          DocumentSelection.collapsed(
            position: DocumentPosition(
              nodeId: newParagraph.id,
              nodePosition: const TextNodePosition(offset: 0),
            ),
          ),
          SelectionChangeType.placeCaret,
          SelectionReason.userInteraction,
        ),
      ]);
    } else {
      if (nodeIndex < _document!.nodeCount - 1) {
        final nextNode = _document!.getNodeAt(nodeIndex + 1);
        if (nextNode is TextNode) {
          _placeCaretAtStartOfTextNode(nextNode.id);
          return;
        }
      }
      final newParagraph = ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(),
      );
      _editor.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: nodeId,
          newNode: newParagraph,
        ),
        ChangeSelectionRequest(
          DocumentSelection.collapsed(
            position: DocumentPosition(
              nodeId: newParagraph.id,
              nodePosition: const TextNodePosition(offset: 0),
            ),
          ),
          SelectionChangeType.placeCaret,
          SelectionReason.userInteraction,
        ),
      ]);
    }
  }

  void _placeCaretAtStartOfTextNode(String nodeId) {
    _editor.execute([
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: nodeId,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.userInteraction,
      ),
    ]);
  }

  void _placeCaretAtEndOfTextNode(String nodeId) {
    final node = _document?.getNodeById(nodeId);
    final textLength = node is TextNode ? node.text.length : 0;
    _editor.execute([
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: nodeId,
            nodePosition: TextNodePosition(offset: textLength),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.userInteraction,
      ),
    ]);
  }

  ExecutionInstruction _customPasteKeyboardAction({
    required SuperEditorContext editContext,
    required KeyEvent keyEvent,
  }) {
    if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
      return ExecutionInstruction.continueExecution;
    }

    if (!keyEvent.isPrimaryShortcutKeyPressed || keyEvent.logicalKey != LogicalKeyboardKey.keyV) {
      return ExecutionInstruction.continueExecution;
    }

    if (editContext.composer.selection == null) {
      return ExecutionInstruction.continueExecution;
    }

    _handlePaste(editContext);
    return ExecutionInstruction.haltExecution;
  }

  Future<void> _handlePaste(SuperEditorContext editContext) async {
    // 1. Check for raw image bytes (e.g. screenshot or copied image from browser)
    try {
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        await _insertImageBytes(imageBytes);
        return;
      }
    } catch (e) {
      debugPrint('Pasteboard image read error: $e');
    }

    // 2. Check for copied files from file manager
    try {
      final files = await Pasteboard.files();
      if (files.isNotEmpty) {
        final imageExtensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.svg'};
        final imageFile = files.firstWhere(
          (f) => imageExtensions.contains(p.extension(f).toLowerCase()),
          orElse: () => '',
        );
        if (imageFile.isNotEmpty) {
          await _insertImageFromFile(File(imageFile));
          return;
        }
      }
    } catch (e) {
      debugPrint('Pasteboard files read error: $e');
    }

    // 3. Check for text that might be an image path or URL
    try {
      final text = await Pasteboard.text;
      if (text != null && text.trim().isNotEmpty) {
        final trimmed = text.trim();
        final imageExtensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.svg'};

        if (File(trimmed).existsSync() && imageExtensions.contains(p.extension(trimmed).toLowerCase())) {
          await _insertImageFromFile(File(trimmed));
          return;
        }

        if (trimmed.startsWith('file://')) {
          final uri = Uri.tryParse(trimmed);
          if (uri != null) {
            final file = File(uri.toFilePath());
            if (file.existsSync() && imageExtensions.contains(p.extension(file.path).toLowerCase())) {
              await _insertImageFromFile(file);
              return;
            }
          }
        }

        if ((trimmed.startsWith('http://') || trimmed.startsWith('https://')) &&
            imageExtensions.contains(p.extension(Uri.tryParse(trimmed)?.path ?? '').toLowerCase())) {
          _insertImageNode(trimmed);
          return;
        }
      }
    } catch (e) {
      debugPrint('Pasteboard text inspection error: $e');
    }

    // 4. Default: delegate to standard text paste
    editContext.commonOps.paste();
  }

  Future<void> _insertImageBytes(Uint8List bytes) async {
    final sourcesDir = Directory(widget.sourcesDirectoryPath);
    if (!await sourcesDir.exists()) {
      await sourcesDir.create(recursive: true);
    }

    final fileName = 'pasted_img_${DateTime.now().millisecondsSinceEpoch}.png';
    final destinationFile = File(p.join(sourcesDir.path, fileName));
    await destinationFile.writeAsBytes(bytes);
    _insertImageNode(destinationFile.path);
  }

  Future<void> _insertImageFromFile(File file) async {
    final sourcesDir = Directory(widget.sourcesDirectoryPath);
    if (!await sourcesDir.exists()) {
      await sourcesDir.create(recursive: true);
    }

    final fileName = p.basename(file.path);
    final destinationFile = File(p.join(sourcesDir.path, fileName));
    try {
      await file.copy(destinationFile.path);
    } catch (e) {
      debugPrint('Error copying image file: $e');
    }
    _insertImageNode(destinationFile.path);
  }

  void _insertImageNode(String imagePath) {
    final selection = _composer.selection;
    String targetNodeId;
    if (selection != null) {
      targetNodeId = selection.extent.nodeId;
    } else if (_document != null && _document!.isNotEmpty) {
      targetNodeId = _document!.last.id;
    } else {
      return;
    }

    final imageNode = ImageNode(
      id: Editor.createNodeId(),
      imageUrl: imagePath,
    );
    final trailingParagraph = ParagraphNode(
      id: Editor.createNodeId(),
      text: AttributedText(),
    );

    _editor.execute([
      InsertNodeAfterNodeRequest(
        existingNodeId: targetNodeId,
        newNode: imageNode,
      ),
      InsertNodeAfterNodeRequest(
        existingNodeId: imageNode.id,
        newNode: trailingParagraph,
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: trailingParagraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.insertContent,
        SelectionReason.userInteraction,
      ),
    ]);
  }

  Future<void> _handleImageInsert() async {
    final result = await FilePicker.pickFile(type: FileType.image);
    if (result == null || result.path == null) return;
    await _insertImageFromFile(File(result.path!));
  }

  Widget _buildCustomImage(BuildContext context, String imageUrl) {
    final effectivePath = imageUrl.split('#').first;
    Widget imageWidget;
    if (effectivePath.startsWith('http://') || effectivePath.startsWith('https://')) {
      imageWidget = Image.network(
        effectivePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildImageError(effectivePath),
      );
    } else {
      // Local file image
      final file = File(effectivePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildImageError(effectivePath),
        );
      } else {
        // Try relative to sourcesDirectoryPath
        final relativeFile = File(p.join(widget.sourcesDirectoryPath, p.basename(effectivePath)));
        if (relativeFile.existsSync()) {
          imageWidget = Image.file(
            relativeFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildImageError(effectivePath),
          );
        } else {
          imageWidget = _buildImageError(effectivePath);
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageWidget,
    );
  }

  Widget _buildImageError(String path) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FLucideIcons.imageOff, size: 18, color: colors.mutedForeground),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Image not found: ${p.basename(path)}',
              style: TextStyle(fontSize: 12, color: colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _document == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final colors = context.theme.colors;

    // Component builders supporting resizable local & network images
    final customComponentBuilders = <ComponentBuilder>[
      const BlockquoteComponentBuilder(),
      const ParagraphComponentBuilder(),
      const ListItemComponentBuilder(),
      ResizableImageComponentBuilder(
        imageBuilder: _buildCustomImage,
        onResize: _handleResizeImage,
        onAlignmentChanged: _handleAlignmentChanged,
        onSelect: _selectImageNode,
        onDeselect: _deselectNode,
        onTapEmptySpace: _handleTapEmptySpaceAroundImage,
        onDelete: _handleDeleteImage,
      ),
      const HorizontalRuleComponentBuilder(),
    ];

    return Container(
      color: colors.card,
      child: Column(
        children: [
          // Formatting toolbar
          ForuiEditorToolbar(
            editor: _editor,
            composer: _composer,
            commonOps: _commonOps,
            onInsertImage: _handleImageInsert,
          ),

          // SuperEditor
          Expanded(
            child: SuperEditor(
              editor: _editor,
              documentLayoutKey: _documentLayoutKey,
              stylesheet: createForuiEditorStylesheet(
                context: context,
                fontFamily: widget.fontFamily,
              ),
              selectionStyle: createForuiSelectionStyles(context),
              documentOverlayBuilders: createForuiDocumentOverlayBuilders(context),
              androidHandleColor: colors.primary,
              iOSHandleColor: colors.primary,
              componentBuilders: customComponentBuilders,
              keyboardActions: [
                _preventTypingOnImageNode,
                _customPasteKeyboardAction,
                ...customEditorKeyboardActions,
                ...defaultKeyboardActions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
