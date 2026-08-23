import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

class ImageEmbed extends StatefulWidget {
  final bool isNetwork;
  final String imageUrl;
  final double initialWidth;

  final Function(double newWidth) onResizeEnd;

  const ImageEmbed({
    super.key,
    required this.imageUrl,
    this.initialWidth = 300,
    required this.onResizeEnd,
    required this.isNetwork,
  });

  @override
  State<ImageEmbed> createState() => _ImageEmbedState();
}

class _ImageEmbedState extends State<ImageEmbed> {
  late double _width;
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  void didUpdateWidget(covariant ImageEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialWidth != oldWidget.initialWidth) {
      setState(() {
        _width = widget.initialWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showHandles = _isHovered || _isDragging;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: SizedBox(
                  width: _width,
                  child: widget.isNetwork
                      ? Image.network(widget.imageUrl, fit: BoxFit.contain, errorBuilder: _buildErrorImage)
                      : Image.file(File(widget.imageUrl), errorBuilder: _buildErrorImage),
                ),
              ),

              // 2. The Right Handle
              if (showHandles)
                Positioned(right: 4, top: 0, bottom: 0, child: _buildDragHandle(isRightHandle: true)),

              // 3. The Left Handle
              if (showHandles)
                Positioned(left: 4, top: 0, bottom: 0, child: _buildDragHandle(isRightHandle: false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage(BuildContext context, Object error, StackTrace? stackTrace) {
    debugPrint('Image load error ($widget.imageUrl): $error');
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey),
            SizedBox(height: 8),
            Text('Unable to load image', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle({required bool isRightHandle}) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            final delta = isRightHandle ? details.delta.dx : -details.delta.dx;
            _width += delta;
          });
        },
        onHorizontalDragEnd: (_) {
          setState(() {
            _isDragging = false;
          });
          widget.onResizeEnd(_width);
        },
        onHorizontalDragCancel: () {
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: 8,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class SourceEmbed extends StatelessWidget {
  final String filename;
  final String filetype;
  final String url;

  const SourceEmbed({super.key, required this.filename, required this.filetype, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: .circular(10)),
      child: UnconstrainedBox(
        child: FButton(
          style: const .delta(contentStyle: .delta(padding: .value(.symmetric(horizontal: 6, vertical: 2)))),
          size: .sm,
          variant: .outline,
          onPress: () {},
          prefix: switch (filetype) {
            'pdf' => const ImageIcon(AssetImage('assets/pdf_icon.png')),
            _ => const Icon(FIcons.file),
          },
          child: Text(filename.length <= 15 ? filename : '${filename.substring(0, 12)}...'),
        ),
      ),
    );
  }
}
