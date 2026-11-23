import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:super_editor/super_editor.dart';

/// A custom view model for [ImageNode] that accurately checks for changes
/// in [expectedSize] and [alignment] so SuperEditor triggers layout updates.
class ResizableImageComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  final String imageUrl;
  final ExpectedSize? expectedSize;
  final String alignment;

  ResizableImageComponentViewModel({
    required super.nodeId,
    super.createdAt,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    super.opacity = 1.0,
    required this.imageUrl,
    this.expectedSize,
    this.alignment = 'center',
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  @override
  ResizableImageComponentViewModel copy() {
    return ResizableImageComponentViewModel(
      nodeId: nodeId,
      createdAt: createdAt,
      maxWidth: maxWidth,
      padding: padding,
      opacity: opacity,
      imageUrl: imageUrl,
      expectedSize: expectedSize,
      alignment: alignment,
      selection: selection,
      selectionColor: selectionColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ResizableImageComponentViewModel &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          createdAt == other.createdAt &&
          imageUrl == other.imageUrl &&
          expectedSize == other.expectedSize &&
          alignment == other.alignment &&
          selection == other.selection &&
          selectionColor == other.selectionColor;

  @override
  int get hashCode =>
      super.hashCode ^
      nodeId.hashCode ^
      createdAt.hashCode ^
      imageUrl.hashCode ^
      expectedSize.hashCode ^
      alignment.hashCode ^
      selection.hashCode ^
      selectionColor.hashCode;
}

/// A component that renders an image within SuperEditor.
///
/// Selection is strictly activated by clicking the image itself (not on hover or empty space).
/// The floating toolbar renders in an [FPopover] over the text layer with zero layout shift.
class ResizableImageComponent extends StatefulWidget {
  final GlobalKey componentKey;
  final String nodeId;
  final String imageUrl;
  final ExpectedSize? expectedSize;
  final String alignment;
  final UpstreamDownstreamNodeSelection? selection;
  final Color selectionColor;
  final Widget Function(BuildContext context, String imageUrl) imageBuilder;
  final void Function(int? width, int? height) onResize;
  final void Function(String alignment)? onAlignmentChanged;
  final VoidCallback? onSelect;
  final VoidCallback? onDeselect;
  final void Function(bool isBefore)? onTapEmptySpace;
  final VoidCallback onDelete;

  const ResizableImageComponent({
    super.key,
    required this.componentKey,
    required this.nodeId,
    required this.imageUrl,
    this.expectedSize,
    this.alignment = 'center',
    this.selection,
    this.selectionColor = Colors.transparent,
    required this.imageBuilder,
    required this.onResize,
    this.onAlignmentChanged,
    this.onSelect,
    this.onDeselect,
    this.onTapEmptySpace,
    required this.onDelete,
  });

  @override
  State<ResizableImageComponent> createState() => _ResizableImageComponentState();
}

class _ResizableImageComponentState extends State<ResizableImageComponent> {
  bool _isSelected = false;
  double? _activeWidth;
  double? _startDragWidth;
  late String _currentAlignment;

  @override
  void initState() {
    super.initState();
    _activeWidth = widget.expectedSize?.width?.toDouble();
    _currentAlignment = widget.alignment;
    _isSelected = widget.selection != null && !widget.selection!.isCollapsed;
  }

  @override
  void didUpdateWidget(ResizableImageComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expectedSize != widget.expectedSize) {
      _activeWidth = widget.expectedSize?.width?.toDouble();
    }
    if (oldWidget.alignment != widget.alignment) {
      _currentAlignment = widget.alignment;
    }

    final isNowSelected = widget.selection != null && !widget.selection!.isCollapsed;
    if (_isSelected != isNowSelected) {
      _isSelected = isNowSelected;
    }
  }

  Alignment _resolveAlignment(String align) {
    switch (align) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return BoxComponent(
      key: widget.componentKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const handlePadding = 12.0;
          final maxWidth = (constraints.maxWidth - handlePadding * 2).clamp(100.0, double.infinity);
          final currentWidth = _activeWidth?.clamp(100.0, maxWidth);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (_isSelected) {
                setState(() => _isSelected = false);
                widget.onDeselect?.call();
              }
              final imageWidth = currentWidth ?? maxWidth;
              final lineCenter = constraints.maxWidth / 2;
              double imageLeft;
              if (_currentAlignment == 'left') {
                imageLeft = 0;
              } else if (_currentAlignment == 'right') {
                imageLeft = constraints.maxWidth - imageWidth;
              } else {
                imageLeft = lineCenter - (imageWidth / 2);
              }
              final isBefore = details.localPosition.dx < imageLeft;
              widget.onTapEmptySpace?.call(isBefore);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: _resolveAlignment(_currentAlignment),
              child: FPopover(
                control: FPopoverControl.lifted(
                  shown: _isSelected,
                  onChange: (shown) {
                    if (_isSelected != shown) {
                      setState(() => _isSelected = shown);
                      if (!shown) {
                        widget.onDeselect?.call();
                      }
                    }
                  },
                ),
                popoverAnchor: Alignment.bottomCenter,
                childAnchor: Alignment.topCenter,
                spacing: const FPortalSpacing(6),
                overflow: FPortalOverflow.flip,
                hideRegion: FPopoverHideRegion.excludeChild,
                onTapHide: () {
                  if (_isSelected) {
                    setState(() => _isSelected = false);
                    widget.onDeselect?.call();
                  }
                },
                popoverBuilder: (context, controller) {
                  return _ImageToolbar(
                    currentWidth: currentWidth ?? maxWidth,
                    maxWidth: maxWidth,
                    currentAlignment: _currentAlignment,
                    onPresetSelected: (ratio) {
                      if (ratio >= 1.0) {
                        setState(() => _activeWidth = null);
                        widget.onResize(null, null);
                      } else {
                        final targetWidth = (maxWidth * ratio).round().toDouble();
                        setState(() => _activeWidth = targetWidth);
                        widget.onResize(targetWidth.round(), null);
                      }
                    },
                    onAlignmentSelected: (align) {
                      setState(() => _currentAlignment = align);
                      widget.onAlignmentChanged?.call(align);
                    },
                    onDelete: () {
                      setState(() => _isSelected = false);
                      widget.onDelete();
                    },
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Image container with 12px hit-test margin
                    Padding(
                      padding: const EdgeInsets.all(handlePadding),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!_isSelected) {
                            setState(() => _isSelected = true);
                            widget.onSelect?.call();
                          }
                        },
                        child: Container(
                          width: currentWidth,
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            minWidth: 100,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isSelected ? colors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: widget.imageBuilder(context, widget.imageUrl),
                          ),
                        ),
                      ),
                    ),

                    // Bottom-Right Drag Handle (visible ONLY when selected)
                    if (_isSelected)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: 24,
                        height: 24,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeDownRight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) {
                              _startDragWidth = currentWidth ?? maxWidth;
                            },
                            onPanUpdate: (details) {
                              final start = _startDragWidth ?? maxWidth;
                              final deltaFactor = _currentAlignment == 'center' ? 2.0 : 1.0;
                              final newWidth = (_activeWidth != null
                                  ? (_activeWidth! + details.delta.dx * deltaFactor)
                                  : (start + details.delta.dx * deltaFactor)).clamp(100.0, maxWidth);
                              setState(() => _activeWidth = newWidth);
                            },
                            onPanEnd: (details) {
                              _startDragWidth = null;
                              if (_activeWidth != null) {
                                widget.onResize(_activeWidth!.round(), null);
                              }
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bottom-Left Drag Handle (visible ONLY when selected)
                    if (_isSelected)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        width: 24,
                        height: 24,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeDownLeft,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) {
                              _startDragWidth = currentWidth ?? maxWidth;
                            },
                            onPanUpdate: (details) {
                              final start = _startDragWidth ?? maxWidth;
                              final deltaFactor = _currentAlignment == 'center' ? 2.0 : 1.0;
                              final newWidth = (_activeWidth != null
                                  ? (_activeWidth! - details.delta.dx * deltaFactor)
                                  : (start - details.delta.dx * deltaFactor)).clamp(100.0, maxWidth);
                              setState(() => _activeWidth = newWidth);
                            },
                            onPanEnd: (details) {
                              _startDragWidth = null;
                              if (_activeWidth != null) {
                                widget.onResize(_activeWidth!.round(), null);
                              }
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Floating mini-toolbar appearing on image selection over the text layer.
class _ImageToolbar extends StatelessWidget {
  final double currentWidth;
  final double maxWidth;
  final String currentAlignment;
  final ValueChanged<double> onPresetSelected;
  final ValueChanged<String> onAlignmentSelected;
  final VoidCallback onDelete;

  const _ImageToolbar({
    required this.currentWidth,
    required this.maxWidth,
    required this.currentAlignment,
    required this.onPresetSelected,
    required this.onAlignmentSelected,
    required this.onDelete,
  });

  bool _isNearRatio(double ratio) {
    final target = maxWidth * ratio;
    return (currentWidth - target).abs() < 12;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current width readout
          Text(
            '${currentWidth.round()}px',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          _toolbarDivider(colors),
          const SizedBox(width: 4),

          // Presets: 25%, 50%, 75%, 100%
          _presetButton(
            context: context,
            label: '25%',
            isActive: _isNearRatio(0.25),
            onTap: () => onPresetSelected(0.25),
          ),
          _presetButton(
            context: context,
            label: '50%',
            isActive: _isNearRatio(0.50),
            onTap: () => onPresetSelected(0.50),
          ),
          _presetButton(
            context: context,
            label: '75%',
            isActive: _isNearRatio(0.75),
            onTap: () => onPresetSelected(0.75),
          ),
          _presetButton(
            context: context,
            label: '100%',
            isActive: _isNearRatio(1.0),
            onTap: () => onPresetSelected(1.0),
          ),

          const SizedBox(width: 4),
          _toolbarDivider(colors),
          const SizedBox(width: 4),

          // Alignment
          _iconButton(
            context: context,
            icon: FLucideIcons.alignLeft,
            tooltip: 'Align Left',
            isActive: currentAlignment == 'left',
            onTap: () => onAlignmentSelected('left'),
          ),
          _iconButton(
            context: context,
            icon: FLucideIcons.alignCenter,
            tooltip: 'Align Center',
            isActive: currentAlignment == 'center',
            onTap: () => onAlignmentSelected('center'),
          ),
          _iconButton(
            context: context,
            icon: FLucideIcons.alignRight,
            tooltip: 'Align Right',
            isActive: currentAlignment == 'right',
            onTap: () => onAlignmentSelected('right'),
          ),

          const SizedBox(width: 4),
          _toolbarDivider(colors),
          const SizedBox(width: 4),

          // Delete image
          _iconButton(
            context: context,
            icon: FLucideIcons.trash2,
            tooltip: 'Delete Image',
            isActive: false,
            color: colors.destructive,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _toolbarDivider(FColors colors) {
    return Container(
      width: 1,
      height: 14,
      color: colors.border,
    );
  }

  Widget _presetButton({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colors = context.theme.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? colors.primary : colors.foreground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required bool isActive,
    Color? color,
    required VoidCallback onTap,
  }) {
    final colors = context.theme.colors;
    final effectiveColor = color ?? (isActive ? colors.primary : colors.foreground);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 14, color: effectiveColor),
          ),
        ),
      ),
    );
  }
}

/// A [ComponentBuilder] for SuperEditor that creates [ResizableImageComponentViewModel]
/// and renders [ImageNode] using [ResizableImageComponent].
class ResizableImageComponentBuilder implements ComponentBuilder {
  final Widget Function(BuildContext context, String imageUrl) imageBuilder;
  final void Function(String nodeId, int? width, int? height) onResize;
  final void Function(String nodeId, String alignment)? onAlignmentChanged;
  final void Function(String nodeId)? onSelect;
  final VoidCallback? onDeselect;
  final void Function(String nodeId, bool isBefore)? onTapEmptySpace;
  final void Function(String nodeId) onDelete;

  const ResizableImageComponentBuilder({
    required this.imageBuilder,
    required this.onResize,
    this.onAlignmentChanged,
    this.onSelect,
    this.onDeselect,
    this.onTapEmptySpace,
    required this.onDelete,
  });

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! ImageNode) {
      return null;
    }

    final align = node.metadata['textAlign'] as String? ?? 'center';

    return ResizableImageComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      imageUrl: node.imageUrl,
      expectedSize: node.expectedBitmapSize,
      alignment: align,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! ResizableImageComponentViewModel) {
      return null;
    }

    return ResizableImageComponent(
      componentKey: componentContext.componentKey,
      nodeId: componentViewModel.nodeId,
      imageUrl: componentViewModel.imageUrl,
      expectedSize: componentViewModel.expectedSize,
      alignment: componentViewModel.alignment,
      selection: componentViewModel.selection?.nodeSelection as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
      imageBuilder: imageBuilder,
      onResize: (width, height) => onResize(componentViewModel.nodeId, width, height),
      onAlignmentChanged: onAlignmentChanged != null
          ? (align) => onAlignmentChanged!(componentViewModel.nodeId, align)
          : null,
      onSelect: onSelect != null ? () => onSelect!(componentViewModel.nodeId) : null,
      onDeselect: onDeselect,
      onTapEmptySpace: onTapEmptySpace != null
          ? (isBefore) => onTapEmptySpace!(componentViewModel.nodeId, isBefore)
          : null,
      onDelete: () => onDelete(componentViewModel.nodeId),
    );
  }
}
