import 'package:flutter/services.dart';
import 'package:super_editor/super_editor.dart';

/// Keyboard action to toggle strikethrough: Ctrl+Shift+X or Ctrl+Shift+S (Cmd+Shift+X on macOS)
ExecutionInstruction toggleStrikethroughWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;

  if (isCtrlOrCmd &&
      isShift &&
      (keyEvent.logicalKey == LogicalKeyboardKey.keyX ||
          keyEvent.logicalKey == LogicalKeyboardKey.keyS)) {
    if (editContext.composer.selection == null) {
      return ExecutionInstruction.continueExecution;
    }

    if (editContext.composer.selection!.isCollapsed) {
      editContext.commonOps.toggleComposerAttributions({strikethroughAttribution});
    } else {
      editContext.commonOps.toggleAttributionsOnSelection({strikethroughAttribution});
    }
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Keyboard action to toggle underline: Ctrl+U (Cmd+U on macOS)
ExecutionInstruction toggleUnderlineWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  if (isCtrlOrCmd && !isShift && !isAlt && keyEvent.logicalKey == LogicalKeyboardKey.keyU) {
    if (editContext.composer.selection == null) {
      return ExecutionInstruction.continueExecution;
    }

    if (editContext.composer.selection!.isCollapsed) {
      editContext.commonOps.toggleComposerAttributions({underlineAttribution});
    } else {
      editContext.commonOps.toggleAttributionsOnSelection({underlineAttribution});
    }
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Keyboard action to toggle inline code: Ctrl+` (backtick) or Ctrl+E (Cmd+` / Cmd+E on macOS)
ExecutionInstruction toggleInlineCodeWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  if (isCtrlOrCmd &&
      !isShift &&
      !isAlt &&
      (keyEvent.logicalKey == LogicalKeyboardKey.backquote ||
          keyEvent.logicalKey == LogicalKeyboardKey.keyE)) {
    if (editContext.composer.selection == null) {
      return ExecutionInstruction.continueExecution;
    }

    if (editContext.composer.selection!.isCollapsed) {
      editContext.commonOps.toggleComposerAttributions({codeAttribution});
    } else {
      editContext.commonOps.toggleAttributionsOnSelection({codeAttribution});
    }
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Keyboard action to toggle quote block: Ctrl+Shift+. or Ctrl+Shift+U (Cmd+Shift+. on macOS)
ExecutionInstruction toggleBlockquoteWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;

  if (isCtrlOrCmd &&
      isShift &&
      (keyEvent.logicalKey == LogicalKeyboardKey.period ||
          keyEvent.logicalKey == LogicalKeyboardKey.keyU)) {
    final selection = editContext.composer.selection;
    if (selection == null) return ExecutionInstruction.continueExecution;

    final node = editContext.document.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return ExecutionInstruction.continueExecution;

    if (node is ParagraphNode && node.getMetadataValue('blockType') == blockquoteAttribution) {
      editContext.commonOps.convertToParagraph();
    } else {
      editContext.commonOps.convertToBlockquote(node.text);
    }
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Keyboard action to toggle code block: Ctrl+Alt+C or Ctrl+Shift+C (Cmd+Alt+C on macOS)
ExecutionInstruction toggleCodeBlockWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  if ((isCtrlOrCmd && isAlt && keyEvent.logicalKey == LogicalKeyboardKey.keyC) ||
      (isCtrlOrCmd && isShift && keyEvent.logicalKey == LogicalKeyboardKey.keyC)) {
    final selection = editContext.composer.selection;
    if (selection == null) return ExecutionInstruction.continueExecution;

    final node = editContext.document.getNodeById(selection.extent.nodeId);
    if (node is! TextNode) return ExecutionInstruction.continueExecution;

    if (node is ParagraphNode && node.getMetadataValue('blockType') == codeAttribution) {
      editContext.commonOps.convertToParagraph();
    } else {
      editContext.editor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: node.id,
          blockType: codeAttribution,
        ),
      ]);
    }
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Keyboard action to toggle headings: Ctrl+Alt+1 (H1), Ctrl+Alt+2 (H2), Ctrl+Alt+3 (H3), Ctrl+Alt+0 (Normal text)
ExecutionInstruction toggleHeadingWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  if (!isCtrlOrCmd || !isAlt) {
    return ExecutionInstruction.continueExecution;
  }

  final selection = editContext.composer.selection;
  if (selection == null) return ExecutionInstruction.continueExecution;

  final node = editContext.document.getNodeById(selection.extent.nodeId);
  if (node is! TextNode) return ExecutionInstruction.continueExecution;

  if (keyEvent.logicalKey == LogicalKeyboardKey.digit0 ||
      keyEvent.logicalKey == LogicalKeyboardKey.numpad0) {
    editContext.commonOps.convertToParagraph();
    return ExecutionInstruction.haltExecution;
  }

  Attribution? targetHeader;
  if (keyEvent.logicalKey == LogicalKeyboardKey.digit1 ||
      keyEvent.logicalKey == LogicalKeyboardKey.numpad1) {
    targetHeader = header1Attribution;
  } else if (keyEvent.logicalKey == LogicalKeyboardKey.digit2 ||
      keyEvent.logicalKey == LogicalKeyboardKey.numpad2) {
    targetHeader = header2Attribution;
  } else if (keyEvent.logicalKey == LogicalKeyboardKey.digit3 ||
      keyEvent.logicalKey == LogicalKeyboardKey.numpad3) {
    targetHeader = header3Attribution;
  }

  if (targetHeader == null) return ExecutionInstruction.continueExecution;

  if (node is ParagraphNode && node.getMetadataValue('blockType') == targetHeader) {
    editContext.commonOps.convertToParagraph();
  } else {
    editContext.editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: node.id,
        blockType: targetHeader,
      ),
    ]);
  }
  return ExecutionInstruction.haltExecution;
}

/// Automatically converts a paragraph starting with ``` followed by space into a code block
class CodeBlockConversionReaction extends ParagraphPrefixConversionReaction {
  static final _codeBlockPattern = RegExp(r'^```\s$');

  const CodeBlockConversionReaction();

  @override
  RegExp get pattern => _codeBlockPattern;

  @override
  void onPrefixMatched(
    EditContext editContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
    ParagraphNode paragraph,
    String match,
  ) {
    requestDispatcher.execute([
      ReplaceNodeRequest(
        existingNodeId: paragraph.id,
        newNode: ParagraphNode(
          id: paragraph.id,
          text: AttributedText(),
          metadata: {
            'blockType': codeAttribution,
          },
        ),
      ),
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: paragraph.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.contentChange,
      ),
    ]);
  }
}

/// Ensures that a document never ends on a non-text block (such as an image).
/// If the last node is not a [TextNode], appends an empty [ParagraphNode].
class EnsureTrailingParagraphReaction extends EditReaction {
  const EnsureTrailingParagraphReaction();

  @override
  void modifyContent(
    EditContext editorContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
  ) {
    final doc = editorContext.document;
    if (doc.isNotEmpty && doc.last is! TextNode) {
      final newParagraph = ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(),
      );
      requestDispatcher.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: doc.last.id,
          newNode: newParagraph,
        ),
      ]);
    }
  }
}

/// Keyboard action to redo: Ctrl+R and Ctrl+Y (in addition to default Ctrl+Shift+Z)
ExecutionInstruction redoWhenShortcutPressed({
  required SuperEditorContext editContext,
  required KeyEvent keyEvent,
}) {
  if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
    return ExecutionInstruction.continueExecution;
  }

  final isCtrlOrCmd = keyEvent.isPrimaryShortcutKeyPressed;
  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;

  if (isCtrlOrCmd && !isShift && !isAlt &&
      (keyEvent.logicalKey == LogicalKeyboardKey.keyR ||
          keyEvent.logicalKey == LogicalKeyboardKey.keyY)) {
    editContext.editor.redo();
    return ExecutionInstruction.haltExecution;
  }

  return ExecutionInstruction.continueExecution;
}

/// Combined list of custom keyboard shortcuts for the SuperEditor screen.
final customEditorKeyboardActions = <SuperEditorKeyboardAction>[
  redoWhenShortcutPressed,
  toggleUnderlineWhenShortcutPressed,
  toggleStrikethroughWhenShortcutPressed,
  toggleInlineCodeWhenShortcutPressed,
  toggleBlockquoteWhenShortcutPressed,
  toggleCodeBlockWhenShortcutPressed,
  toggleHeadingWhenShortcutPressed,
];
