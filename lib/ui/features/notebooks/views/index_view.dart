import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart' hide Delta;
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';
// import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/ui/features/notebooks/cubits/index_cubit.dart';
import 'package:studyapp/ui/shared/widgets/fleather_editor.dart';
import 'package:studyapp/ui/shared/widgets/fleather_toolbar.dart';
import 'package:studyapp/ui/shared/widgets/fleather_viewer.dart';

class IndexPage extends StatelessWidget {
  final int notebookId;
  const IndexPage({super.key, required this.notebookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IndexCubit(
        uiPreferencesRepository: context.read<UiPreferencesRepository>(),
        notebookId: notebookId,
      ),
      child: IndexView(notebookId: notebookId),
    );
  }
}

class IndexView extends StatefulWidget {
  final int notebookId;
  const IndexView({super.key, required this.notebookId});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> with AutomaticKeepAliveClientMixin {
  // final customInteractiveViewerController = CustomInteractiveViewerController();
  final horizontalScrollController = ScrollController();
  bool activeEditor = false;
  VoidCallback? activeSaveCallback;

  bool checkAndSetActive(VoidCallback saveFunction) {
    if (activeEditor == true) {
      // Perhaps a popup message that another editor is already active
      return false;
    }
    activeEditor = true;
    activeSaveCallback = saveFunction;
    return true;
  }

  void removeActive() {
    activeSaveCallback = null;
    activeEditor = false;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.theme.colors;
    return BlocBuilder<IndexCubit, IndexState>(
      builder: (context, state) {
        switch (state) {
          case IndexLoading():
            return const CircularProgressIndicator();
          case IndexReady():
            return Stack(
              children: [
                InteractiveViewer2(
                  // controller: customInteractiveViewerController,
                  // interactionConfig: const .new(constrainBounds: true),
                  // zoomConfig: const .new(minScale: 0.2),
                  showScrollbars: true,
                  constrained: false,
                  noMouseDragScroll: false,
                  interactionEndFrictionCoefficient: 0.001,
                  allowNonCoveringScreenZoom: true,
                  minScale: 0.3,
                  maxScale: 3.5,
                  scaleFactor: 900,
                  // panEnabled: _canPan,
                  child: Container(
                    // width: 1200,
                    constraints: const BoxConstraints(minHeight: 1000, minWidth: 1200),
                    decoration: BoxDecoration(
                      color: colors.card,
                      // color: Colors.white,
                      border: .all(width: 2, color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(72.0),
                          child: Text(
                            "Index",
                            style: context.theme.typography.xl7.copyWith(
                              fontFamily: 'Source Sans 3',
                              fontWeight: .bold,
                            ),
                            // style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: .w800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 48, left: 48, right: 48),
                          child: IndexContent(
                            content: state.content,
                            checkAndSetActive: checkAndSetActive,
                            removeActive: removeActive,
                            noOfColumns: state.noOfColumns,
                            tableWidth: 1100,
                            headers: state.headers,
                            columnWidths: state.columnWidths,
                            notebookId: widget.notebookId,
                          ),
                        ),
                        Align(
                          alignment: .centerRight,
                          child: FButton(
                            mainAxisSize: .min,
                            onPress: () {
                              debugPrint(state.content.toString());
                            },
                            child: const Text("Print state"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: SizedBox(
                    height: 60,
                    width: 120,
                    child: state.inEditMode
                        ? FButton(
                            style: .delta(
                              decoration: .delta([
                                .base(const .boxDelta(color: Colors.green)),
                                .exact({.hovered}, .boxDelta(color: Colors.green[700])),
                                .match({
                                  .disabled,
                                }, .boxDelta(color: Colors.green.withAlpha((0.4 * 255).toInt()))),
                              ]),
                            ),
                            size: .lg,
                            onPress: () {
                              context.read<IndexCubit>().toggleEditMode();
                              if (activeSaveCallback != null) activeSaveCallback!();
                            },
                            prefix: const Icon(FIcons.check, size: 20),
                            child: const Text("Done", style: .new(fontSize: 18)),
                          )
                        : FButton(
                            size: .lg,
                            onPress: () {
                              context.read<IndexCubit>().toggleEditMode();
                            },
                            prefix: const Icon(FIcons.pencilLine, size: 20),
                            child: const Text("Edit", style: .new(fontSize: 18)),
                          ),
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

class IndexContent extends StatefulWidget {
  final int notebookId;
  final List<({int id, List<String> data})> content;
  final List<String> headers;
  // final List<List<String?>> content;
  final List<double> columnWidths;
  final double tableWidth;
  final int noOfColumns;
  final bool Function(VoidCallback saveFunction) checkAndSetActive;
  final void Function() removeActive;
  const IndexContent({
    super.key,
    required this.content,
    required this.checkAndSetActive,
    required this.removeActive,
    required this.noOfColumns,
    required this.tableWidth,
    required this.headers,
    required this.columnWidths,
    required this.notebookId,
  });

  @override
  State<IndexContent> createState() => _IndexContentState();
}

class _IndexContentState extends State<IndexContent> {
  // late Map<int, TableColumnWidth> columnWidths;
  // final tableScrollController = ScrollController();
  // late List<double> columnWidths;
  int? activeId;
  int? activeCol;
  final double minColumnWidth = 50;

  @override
  void initState() {
    super.initState();
  }

  TableRow generateHeaders() {
    return TableRow(
      children: widget.headers.mapIndexed((index, header) {
        return Stack(
          children: [
            // The Actual Header Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            // The Hit-Test Target for Draggable Border (Positioned on the far right)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 10, // Width of the invisible dragging hot-spot
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    double newWidth;
                    setState(() {
                      // Calculate new width ensuring it doesn't drop below the minimum
                      newWidth = widget.columnWidths[index] + details.delta.dx;
                      if (newWidth > minColumnWidth) {
                        widget.columnWidths[index] = newWidth;
                      }
                    });
                    // context.read<IndexCubit>().saveColumnWidths(widget.notebookId, widget.columnWidths);
                  },
                  onHorizontalDragEnd: (details) {
                    context.read<IndexCubit>().saveColumnWidths(widget.notebookId, widget.columnWidths);
                  },
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Table(
      columnWidths: {
        for (int i = 0; i < widget.noOfColumns; i++) i: FixedColumnWidth(widget.columnWidths[i]),
      },
      border: TableBorder(
        top: BorderSide(color: colors.border, width: 2),
        right: BorderSide(color: colors.border, width: 2),
        bottom: BorderSide(color: colors.border, width: 2),
        left: BorderSide(color: colors.border, width: 2),
        horizontalInside: BorderSide(color: colors.border, width: 2),
        verticalInside: BorderSide(color: colors.border, width: 2),
        borderRadius: .circular(10),
      ),
      children: [
        generateHeaders(),
        ...widget.content.map((row) {
          return TableRow(
            children: [
              ...List<Widget>.generate(widget.noOfColumns, (int index) {
                if (index >= row.data.length) {
                  // return const TableCell(child: Text(""));
                  row.data.add(jsonEncode(Delta()..insert('\n')));
                }
                final List<dynamic> rawDelta = jsonDecode(row.data[index]);
                final Delta dataDelta = Delta.fromJson(rawDelta);

                // bool isStretched = activeId == row.id && activeCol == index;

                return TableCell(
                  // verticalAlignment: isStretched ? .fill : null,
                  child: EditableFleatherCell(
                    initialDelta: dataDelta,
                    saveData: (delta) {
                      // context.read<IndexCubit>().editUnitDesc(row.id, jsonEncode(delta));
                      context.read<IndexCubit>().editUnitData(row.id, index, jsonEncode(delta));
                    },
                    checkAndSetActive: widget.checkAndSetActive,
                    removeActive: widget.removeActive,
                    id: row.id,
                    // currentlyActive: (bool value) {
                    //   setState(() {
                    //     if (value) {
                    //       activeId = row.id;
                    //       activeCol = index;
                    //     } else {
                    //       activeId = null;
                    //       activeCol = null;
                    //     }
                    //   });
                    // },
                  ),
                );
              }, growable: false),
            ],
          );
        }),
      ],
    );
  }
}

class EditableFleatherCell extends StatefulWidget {
  final int id;
  final Function(Delta delta) saveData;
  final Delta initialDelta;
  final bool Function(VoidCallback saveFunction) checkAndSetActive;
  final void Function() removeActive;
  // final ValueChanged<bool> currentlyActive;
  const EditableFleatherCell({
    super.key,
    required this.initialDelta,
    required this.saveData,
    required this.checkAndSetActive,
    required this.removeActive,
    required this.id,
    // required this.currentlyActive,
  });
  @override
  State<EditableFleatherCell> createState() => EditableFleatherCellState();
}

class EditableFleatherCellState extends State<EditableFleatherCell> {
  FleatherController? controller;
  bool isEditing = false;

  void save() {
    widget.removeActive();
    final Delta delta = controller!.document.toDelta();
    debugPrint(delta.toString());
    widget.saveData(delta);
    controller!.dispose();
    setState(() {
      isEditing = false;
    });
    // widget.currentlyActive(false);
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      controller = FleatherController(document: .fromDelta(widget.initialDelta));
      return CustomFleatherEditor(
        controller: controller!,
        contextMenuBuilder: (context, editorState) {
          final anchors = editorState.contextMenuAnchors;
          print(anchors.primaryAnchor);
          return Transform.translate(
            offset: Offset(anchors.primaryAnchor.dx - 501, anchors.primaryAnchor.dy - 410),
            child: UnconstrainedBox(child: CustomFleatherToolbar(controller: controller!)),
          );
        },
        save: save,
      );
    } else {
      if (context.read<IndexCubit>().readyState.inEditMode) {
        return GestureDetector(
          behavior: .opaque,
          onTap: () {
            // if (!context.read<IndexCubit>().state.inEditMode) {
            //   return;
            // }
            if (!widget.checkAndSetActive(save)) {
              return;
            }
            setState(() {
              isEditing = true;
            });

            // widget.currentlyActive(true);
          },

          child: IgnorePointer(child: FleatherViewer(delta: widget.initialDelta)),
        );
      } else {
        return FleatherViewer(delta: widget.initialDelta);
      }
    }
  }
}
