import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/features/notebooks/cubits/note_cubit.dart';
import 'package:studyapp/ui/shared/widgets/fleather_toolbar.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteCubit(notebookRepository: context.read<NotebookRepository>()),
      child: const NotesView(),
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FleatherController controller;

  @override
  void initState() {
    super.initState();

    final doc = ParchmentDocument();
    doc.insert(
      0,
      'Welcome to Fleather!\nClick the button below to append an image embed to the very end of this document.\n',
    );
    controller = FleatherController(document: doc);

    controller.replaceText(controller.document.length - 1, 0, "\n");
    final imageEmbed = EmbeddableObject(
      'image',
      inline: false,
      data: {
        'source':
            'https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      },
    );

    controller.replaceText(controller.document.length - 1, 0, imageEmbed);
    controller.updateSelection(TextSelection.collapsed(offset: controller.document.length - 1));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return BlocBuilder<NoteCubit, NoteState>(
      builder: (context, state) {
        // TODO: Make the note cubit work
        // controller = .new(document: .fromJson(state.data));
        return Column(
          children: [
            CustomFleatherToolbar(controller: controller),
            Expanded(
              child: InteractiveViewer2(
                showScrollbars: true,
                constrained: false,
                noMouseDragScroll: true,
                interactionEndFrictionCoefficient: 0.001,
                allowNonCoveringScreenZoom: true,
                minScale: 0.3,
                maxScale: 3.5,
                scaleFactor: 900,
                child: Container(
                  width: 1200,
                  height: 5000,
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: .all(width: 2, color: colors.border),
                    borderRadius: .circular(10),
                  ),
                  child: Padding(
                    padding: const .all(48),
                    child: Column(
                      children: [
                        FleatherEditor(
                          controller: controller,
                          autofocus: true,
                          embedBuilder: (BuildContext context, EmbedNode node) {
                            // Handling source pills
                            if (node.value.type == 'source') {
                              return SourceEmbed(
                                filename: node.value.data['filename'],
                                filetype: node.value.data['filetype'],
                                url: node.value.data['url'],
                              );
                            }

                            // Handling images
                            if (node.value.type == 'image') {
                              final imageUrl = node.value.data['source'] as String;
                              final currentWidth = (node.value.data['width'] as double?) ?? 300.0;

                              return ImageEmbed(
                                imageUrl: imageUrl,
                                initialWidth: currentWidth,
                                onResizeEnd: (newWidth) {
                                  final index = node.documentOffset;
                                  final length = node.length;

                                  final newData = Map<String, dynamic>.from(node.value.data);
                                  newData['width'] = newWidth;
                                  // using embeddable object here because using blockembed causes extra space on top
                                  controller.replaceText(
                                    index,
                                    length,
                                    EmbeddableObject('image', inline: true, data: newData),
                                  );
                                },
                              );
                            }

                            // 3. Fall back to Fleather's native horizontal rule builder safely
                            return defaultFleatherEmbedBuilder(context, node);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ImageEmbed extends StatefulWidget {
  final String imageUrl;
  final double initialWidth;

  final Function(double newWidth) onResizeEnd;

  const ImageEmbed({super.key, required this.imageUrl, this.initialWidth = 300, required this.onResizeEnd});

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
              // 1. The Image
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: SizedBox(
                  width: _width,
                  child: Image.network(widget.imageUrl, fit: BoxFit.contain),
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
      // width: 80,
      // height: 20,
      child: UnconstrainedBox(
        child: FButton(
          style: const .delta(contentStyle: .delta(padding: .value(.symmetric(horizontal: 6, vertical: 2)))),
          size: .sm,
          variant: .outline,
          onPress: () {},
          prefix: Icon(filetype == 'pdf' ? FIcons.file : FIcons.menu),
          child: Text(filename.length <= 15 ? filename : '${filename.substring(0, 12)}...'),
        ),
      ),
    );
  }
}
