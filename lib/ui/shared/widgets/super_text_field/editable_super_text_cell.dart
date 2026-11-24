import 'dart:async';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_editor/super_editor.dart';
import 'package:studyapp/ui/shared/widgets/super_text_field/cell_content_serializer.dart';

/// An editable table cell backed by [SuperTextField] for rich text editing,
/// with an integrated formatting toolbar built directly into the cell container,
/// instant auto-commit on cell-to-cell focus switching, auto-expanding height
/// with zero scrollbars, and debounced auto-saving.
class EditableSuperTextCell extends StatefulWidget {
  final int id;
  final int columnIndex;
  final String? initialData;
  final void Function(String serializedMarkdown) saveData;
  final bool Function(VoidCallback saveFunction) requestActivation;
  final VoidCallback removeActive;
  final bool inEditMode;
  final String? fontFamily;

  const EditableSuperTextCell({
    super.key,
    required this.id,
    required this.columnIndex,
    required this.initialData,
    required this.saveData,
    required this.requestActivation,
    required this.removeActive,
    required this.inEditMode,
    this.fontFamily,
  });

  @override
  State<EditableSuperTextCell> createState() => _EditableSuperTextCellState();
}

class _EditableSuperTextCellState extends State<EditableSuperTextCell> {
  AttributedTextEditingController? _controller;
  FocusNode? _focusNode;
  bool _isEditing = false;
  bool _isSaving = false;
  late AttributedText _currentAttributedText;
  Timer? _debounceTimer;
  int _lastLineCount = 1;

  @override
  void initState() {
    super.initState();
    _currentAttributedText = CellContentSerializer.parse(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant EditableSuperTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData && !_isEditing) {
      _currentAttributedText = CellContentSerializer.parse(widget.initialData);
    }
    // If edit mode was toggled off while this cell was active, commit immediately
    if (oldWidget.inEditMode && !widget.inEditMode && _isEditing) {
      save();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller?.removeListener(_onTextChanged);
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  int get _lineCount {
    if (_controller == null || _controller!.text.isEmpty) return 1;
    final plain = _controller!.text.toPlainText();
    return plain.split('\n').length.clamp(1, 1000);
  }

  void _onTextChanged() {
    if (_controller == null) return;
    _currentAttributedText = _controller!.text;

    // Dynamically expand the cell height when new lines are added or removed
    final currentLines = _lineCount;
    if (currentLines != _lastLineCount) {
      _lastLineCount = currentLines;
      if (mounted) {
        setState(() {});
      }
    }

    // Debounced silent background auto-save to database (600ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted || _controller == null) return;
      widget.saveData(CellContentSerializer.serialize(_controller!.text));
    });
  }

  void save() {
    if (!_isEditing || _isSaving) return;
    _isSaving = true;

    _debounceTimer?.cancel();
    widget.removeActive();

    // Immediately extract text and persist to SQLite
    final currentController = _controller;
    if (currentController != null) {
      _currentAttributedText = currentController.text;
      widget.saveData(CellContentSerializer.serialize(_currentAttributedText));
    }

    // Unfocus immediately so active keyboard and gesture arenas release
    _focusNode?.unfocus();

    // Defer unmounting to the next frame. This allows any active pointer gesture or
    // pan recognizer in SuperDesktopTextField to finish cancelling cleanly before
    // its internal ticker and scroll views are disposed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final controllerToDispose = _controller;
      _controller = null;
      if (controllerToDispose != null) {
        controllerToDispose.removeListener(_onTextChanged);
        scheduleMicrotask(() => controllerToDispose.dispose());
      }

      final focusNodeToDispose = _focusNode;
      _focusNode = null;
      if (focusNodeToDispose != null) {
        scheduleMicrotask(() => focusNodeToDispose.dispose());
      }

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    });
  }

  void _toggleAttribution(Attribution attribution) {
    if (_controller == null) return;
    if (_controller!.selection.isCollapsed) {
      _controller!.toggleComposingAttributions({attribution});
    } else {
      _controller!.toggleSelectionAttributions([attribution]);
    }
  }

  bool _isAttributionActive(Attribution attribution) {
    if (_controller == null) return false;
    if (_controller!.composingAttributions.contains(attribution)) {
      return true;
    }
    if (_controller!.text.isEmpty) {
      return false;
    }
    if (_controller!.selection.isCollapsed) {
      final extent = _controller!.selection.extentOffset;
      if (extent <= 0) {
        return _controller!.text.hasAttributionAt(0, attribution: attribution);
      }
      final offset = (extent - 1).clamp(0, _controller!.text.length - 1);
      return _controller!.text.hasAttributionAt(offset, attribution: attribution);
    }
    final start = _controller!.selection.start;
    final end = (_controller!.selection.end - 1).clamp(0, _controller!.text.length - 1);
    if (start > end) return false;
    return _controller!.text.hasAttributionsWithin(
      attributions: {attribution},
      range: SpanRange(start, end),
    );
  }

  void _activateEditor() {
    // Coordinate with parent: flush any previously active cell and claim active status
    if (!widget.requestActivation(save)) {
      return;
    }

    _isSaving = false;
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      // If focus is lost and we are still editing and not already saving, trigger save
      if (_focusNode != null && !_focusNode!.hasFocus && _isEditing && !_isSaving) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isEditing && !_isSaving && (_focusNode == null || !_focusNode!.hasFocus)) {
            save();
          }
        });
      }
    });

    _controller = AttributedTextEditingController(
      text: _currentAttributedText.copyText(0),
    );
    _lastLineCount = _lineCount;
    _controller!.addListener(_onTextChanged);

    setState(() {
      _isEditing = true;
    });

    // Request keyboard focus on the newly mounted SuperTextField
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode != null && _focusNode!.canRequestFocus) {
        _focusNode!.requestFocus();
      }
    });
  }

  TextStyle _cellStyleBuilder(Set<Attribution> attributions, FColors colors) {
    TextStyle style = TextStyle(
      fontSize: 14,
      color: colors.foreground,
      fontFamily: widget.fontFamily,
      height: 1.4,
    );

    if (attributions.contains(boldAttribution)) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }
    if (attributions.contains(italicsAttribution)) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (attributions.contains(underlineAttribution)) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    if (attributions.contains(strikethroughAttribution)) {
      style = style.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (attributions.contains(codeAttribution)) {
      style = style.copyWith(
        fontFamily: 'JetBrains Mono',
        backgroundColor: colors.muted.withAlpha(50),
      );
    }

    return style;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    if (_isEditing && _controller != null) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
            _toggleAttribution(boldAttribution);
          },
          const SingleActivator(LogicalKeyboardKey.keyI, control: true): () {
            _toggleAttribution(italicsAttribution);
          },
          const SingleActivator(LogicalKeyboardKey.keyU, control: true): () {
            _toggleAttribution(underlineAttribution);
          },
          const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true): () {
            _toggleAttribution(strikethroughAttribution);
          },
          const SingleActivator(LogicalKeyboardKey.backquote, control: true): () {
            _toggleAttribution(codeAttribution);
          },
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            save();
          },
        },
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            border: Border.all(color: colors.primary, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Integrated Toolbar Bar at top of the active cell
              ExcludeFocus(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.muted.withAlpha(50),
                    border: Border(
                      bottom: BorderSide(color: colors.border.withAlpha(120), width: 1),
                    ),
                  ),
                  child: ListenableBuilder(
                    listenable: _controller!,
                    builder: (context, _) {
                      return _CellFormattingToolbar(
                        isBold: _isAttributionActive(boldAttribution),
                        isItalic: _isAttributionActive(italicsAttribution),
                        isUnderline: _isAttributionActive(underlineAttribution),
                        isStrikethrough: _isAttributionActive(strikethroughAttribution),
                        isCode: _isAttributionActive(codeAttribution),
                        onToggleBold: () => _toggleAttribution(boldAttribution),
                        onToggleItalic: () => _toggleAttribution(italicsAttribution),
                        onToggleUnderline: () => _toggleAttribution(underlineAttribution),
                        onToggleStrikethrough: () => _toggleAttribution(strikethroughAttribution),
                        onToggleCode: () => _toggleAttribution(codeAttribution),
                        onSave: save,
                      );
                    },
                  ),
                ),
              ),

              // 2. Editor Text Area with suppressed scrollbars and auto-expanding line height
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: IgnorePointer(
                  ignoring: _isSaving,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ScrollbarTheme(
                      data: const ScrollbarThemeData(
                        thumbVisibility: WidgetStatePropertyAll(false),
                        trackVisibility: WidgetStatePropertyAll(false),
                        thickness: WidgetStatePropertyAll(0.0),
                      ),
                      child: SuperTextField(
                        focusNode: _focusNode,
                        textController: _controller,
                        textStyleBuilder: (attributions) => _cellStyleBuilder(attributions, colors),
                        minLines: _lineCount,
                        maxLines: null,
                        blinkTimingMode: BlinkTimingMode.timer,
                        caretStyle: CaretStyle(
                          color: colors.foreground,
                          width: 2,
                          borderRadius: BorderRadius.zero,
                        ),
                        selectionColor: colors.primary.withAlpha(80),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Static Viewer Mode (ultra-lightweight painting)
    final inlineSpan = _currentAttributedText.computeInlineSpan(
      context,
      (attributions) => _cellStyleBuilder(attributions, colors),
      const [],
    );

    final viewer = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: _currentAttributedText.isEmpty
          ? (widget.inEditMode
              ? Text(
                  'Click to edit...',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colors.mutedForeground.withAlpha(120),
                    fontFamily: widget.fontFamily,
                  ),
                )
              : const SizedBox(height: 18))
          : Text.rich(inlineSpan),
    );

    if (widget.inEditMode) {
      return MouseRegion(
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activateEditor,
          child: viewer,
        ),
      );
    }

    return viewer;
  }
}

/// Formatting toolbar integrated directly into the header of an active table cell.
class _CellFormattingToolbar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final bool isCode;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;
  final VoidCallback onToggleStrikethrough;
  final VoidCallback onToggleCode;
  final VoidCallback onSave;

  const _CellFormattingToolbar({
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.isStrikethrough,
    required this.isCode,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
    required this.onToggleStrikethrough,
    required this.onToggleCode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarButton(
          label: 'Bold',
          shortcut: 'Ctrl+B',
          isActive: isBold,
          onPressed: onToggleBold,
          child: const Icon(FLucideIcons.bold, size: 14),
        ),
        const SizedBox(width: 2),
        _ToolbarButton(
          label: 'Italic',
          shortcut: 'Ctrl+I',
          isActive: isItalic,
          onPressed: onToggleItalic,
          child: const Icon(FLucideIcons.italic, size: 14),
        ),
        const SizedBox(width: 2),
        _ToolbarButton(
          label: 'Underline',
          shortcut: 'Ctrl+U',
          isActive: isUnderline,
          onPressed: onToggleUnderline,
          child: const Icon(FLucideIcons.underline, size: 14),
        ),
        const SizedBox(width: 2),
        _ToolbarButton(
          label: 'Strikethrough',
          shortcut: 'Ctrl+Shift+S',
          isActive: isStrikethrough,
          onPressed: onToggleStrikethrough,
          child: const Icon(FLucideIcons.strikethrough, size: 14),
        ),
        const SizedBox(width: 2),
        _ToolbarButton(
          label: 'Inline Code',
          shortcut: 'Ctrl+`',
          isActive: isCode,
          onPressed: onToggleCode,
          child: const Icon(FLucideIcons.code, size: 14),
        ),
        _buildDivider(colors.border),
        _ToolbarButton(
          label: 'Save & Done',
          shortcut: 'Ctrl+S',
          isActive: false,
          onPressed: onSave,
          colorOverride: Colors.green,
          child: const Icon(FLucideIcons.check, size: 15, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: borderColor.withAlpha(120),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final String label;
  final String shortcut;
  final bool isActive;
  final VoidCallback onPressed;
  final Widget child;
  final Color? colorOverride;

  const _ToolbarButton({
    required this.label,
    required this.shortcut,
    required this.isActive,
    required this.onPressed,
    required this.child,
    this.colorOverride,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    Color? bg;
    if (widget.isActive) {
      bg = (widget.colorOverride ?? colors.primary).withAlpha(50);
    } else if (_isHovered) {
      bg = colors.muted.withAlpha(60);
    }

    final fg = widget.isActive
        ? (widget.colorOverride ?? colors.primary)
        : (widget.colorOverride ?? colors.foreground);

    return Tooltip(
      message: '${widget.label} (${widget.shortcut})',
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
              border: widget.isActive
                  ? Border.all(color: (widget.colorOverride ?? colors.primary).withAlpha(100), width: 1)
                  : null,
            ),
            alignment: Alignment.center,
            child: IconTheme(
              data: IconThemeData(color: fg, size: 14),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
