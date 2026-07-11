import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart' hide Delta;
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/data/repositories/index_respository.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';
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
        indexRepository: context.read<IndexRepository>(),
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
  final horizontalScrollController = ScrollController();
  bool activeEditor = false;
  VoidCallback? activeSaveCallback;

  bool checkAndSetActive(VoidCallback saveFunction) {
    if (activeEditor == true) {
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
            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
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
              ),
              body: Stack(
                children: [
                  InteractiveViewer2(
                    showScrollbars: true,
                    constrained: false,
                    noMouseDragScroll: false,
                    interactionEndFrictionCoefficient: 0.001,
                    allowNonCoveringScreenZoom: true,
                    minScale: 0.3,
                    maxScale: 3.5,
                    scaleFactor: 900,
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 1000),
                          decoration: BoxDecoration(
                            color: colors.card,
                            border: .all(width: 2, color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(72.0),
                                child: Text(
                                  "Index",
                                  style: context.theme.typography.xl7.copyWith(
                                    fontFamily: 'Source Sans 3',
                                    fontWeight: FontWeight.bold,
                                  ),
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

                              FButton(
                                onPress: () {
                                  context.read<IndexCubit>().deleteAllItems();
                                },
                                child: const Text("Delete everything"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class IndexContent extends StatefulWidget {
  final int notebookId;
  final List<({int id, List<String?> data})> content;
  final List<String?> headers;
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
  final double minColumnWidth = 50;

  late ValueNotifier<List<double>> widthsNotifier;
  final ValueNotifier<double?> dragPositionNotifier = ValueNotifier(null);

  int _draggingColIndex = -1;

  final ValueNotifier<int?> hoveredSeamNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    widthsNotifier = ValueNotifier(List.from(widget.columnWidths));
  }

  @override
  void didUpdateWidget(covariant IndexContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columnWidths != widget.columnWidths) {
      widthsNotifier.value = List.from(widget.columnWidths);
    }
  }

  @override
  void dispose() {
    widthsNotifier.dispose();
    dragPositionNotifier.dispose();
    hoveredSeamNotifier.dispose();
    super.dispose();
  }

  Widget _buildHeaderRow(Color borderColor, bool inEditMode) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.headers.mapIndexed((index, header) {
              return ValueListenableBuilder<List<double>>(
                valueListenable: widthsNotifier,
                builder: (context, currentWidths, child) {
                  return Container(
                    width: currentWidths[index],
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < widget.headers.length - 1
                            ? BorderSide(color: borderColor, width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(header ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          width: 10,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.resizeLeftRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragStart: (details) {
                                _draggingColIndex = index;
                                double startX = 0;
                                for (int i = 0; i <= index; i++) {
                                  startX += widthsNotifier.value[i];
                                }
                                dragPositionNotifier.value = startX;
                              },
                              onHorizontalDragUpdate: (details) {
                                if (dragPositionNotifier.value == null) return;
                                double newX = dragPositionNotifier.value! + details.delta.dx;
                                double minAllowedX = 0;
                                for (int i = 0; i < index; i++) {
                                  minAllowedX += widthsNotifier.value[i];
                                }
                                minAllowedX += minColumnWidth;
                                if (newX >= minAllowedX) dragPositionNotifier.value = newX;
                              },
                              onHorizontalDragEnd: (details) {
                                if (_draggingColIndex != -1 && dragPositionNotifier.value != null) {
                                  double startColX = 0;
                                  for (int i = 0; i < _draggingColIndex; i++) {
                                    startColX += widthsNotifier.value[i];
                                  }
                                  double finalWidth = dragPositionNotifier.value! - startColX;
                                  final newWidths = List<double>.from(widthsNotifier.value);
                                  newWidths[_draggingColIndex] = finalWidth;
                                  widthsNotifier.value = newWidths;
                                  context.read<IndexCubit>().saveColumnWidths(widget.notebookId, newWidths);
                                }
                                dragPositionNotifier.value = null;
                                _draggingColIndex = -1;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),

        // This is for the first row because half of top for row1 is in the header itself
        if (inEditMode)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HoverInsertBox(
              seamIndex: 0,
              hoveredSeamNotifier: hoveredSeamNotifier,
              onInsert: () {
                context.read<IndexCubit>().addUnit(position: 0);
                print("Adding to the first row");
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final inEditMode = context.read<IndexCubit>().readyState.inEditMode;

    return ValueListenableBuilder<List<double>>(
      valueListenable: widthsNotifier,
      builder: (context, currentWidths, _) {
        final innerColumnsWidth = currentWidths.fold(0.0, (prev, width) => prev + width);
        final currentTableWidth = innerColumnsWidth + 4.0;

        return Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: .none,
              children: [
                Container(
                  // borderRadius: .circular(10),
                  width: currentTableWidth,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildHeaderRow(colors.border, inEditMode),

                          ...widget.content.mapIndexed((rowIndex, row) {
                            final isLastRow = rowIndex == widget.content.length - 1;

                            return ConstrainedBox(
                              key: ValueKey(row.id),
                              constraints: const .new(minHeight: 50),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: colors.border, width: 2)),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: List.generate(widget.noOfColumns, (columnIndex) {
                                          if (columnIndex >= row.data.length) {
                                            row.data.add(jsonEncode(Delta()..insert('\n')));
                                          }
                                          final List<dynamic> rawDelta = jsonDecode(
                                            row.data[columnIndex] ?? "[]",
                                          );
                                          final Delta dataDelta = rawDelta.isNotEmpty
                                              ? Delta.fromJson(rawDelta)
                                              : ParchmentDocument().toDelta();

                                          // final cachedFleatherCell =
                                          return ValueListenableBuilder<List<double>>(
                                            valueListenable: widthsNotifier,
                                            // child: cachedFleatherCell,
                                            builder: (context, currentWidths, child) {
                                              return Container(
                                                width: currentWidths[columnIndex],
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: columnIndex < widget.noOfColumns - 1
                                                        ? BorderSide(color: colors.border, width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                ),
                                                child: EditableFleatherCell(
                                                  initialDelta: dataDelta,
                                                  saveData: (delta) {
                                                    context.read<IndexCubit>().editUnitData(
                                                      row.id,
                                                      columnIndex,
                                                      jsonEncode(delta),
                                                    );
                                                  },
                                                  checkAndSetActive: widget.checkAndSetActive,
                                                  removeActive: widget.removeActive,
                                                  id: row.id,
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                  ),

                                  if (inEditMode)
                                    ValueListenableBuilder<int?>(
                                      valueListenable: hoveredSeamNotifier,
                                      builder: (context, hoveredSeam, child) {
                                        if (hoveredSeam == rowIndex) {
                                          return Positioned(
                                            top: -1,
                                            left: 0,
                                            right: 0,
                                            child: Container(height: 4, color: Colors.blue),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),

                                  if (inEditMode)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: HoverInsertBox(
                                        seamIndex: rowIndex,
                                        hoveredSeamNotifier: hoveredSeamNotifier,
                                        onInsert: () {
                                          context.read<IndexCubit>().addUnit(position: rowIndex);
                                          print("Inserting before row: $rowIndex");
                                        },
                                      ),
                                    ),

                                  if (inEditMode && !isLastRow)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: HoverInsertBox(
                                        seamIndex: rowIndex + 1,
                                        hoveredSeamNotifier: hoveredSeamNotifier,
                                        onInsert: () {
                                          context.read<IndexCubit>().addUnit(position: rowIndex + 1);
                                          print("Inserting before row: ${rowIndex + 1}");
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Proxy Drag Line
                ValueListenableBuilder<double?>(
                  valueListenable: dragPositionNotifier,
                  builder: (context, dragX, child) {
                    if (dragX == null) return const SizedBox.shrink();
                    return Positioned(
                      left: dragX,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 3, color: Colors.blue.withAlpha(200)),
                    );
                  },
                ),
              ],
            ),

            if (inEditMode)
              SizedBox(
                width: currentTableWidth,
                child: FButton(
                  variant: .outline,
                  onPress: () {
                    print("Appending to bottom of table");
                    context.read<IndexCubit>().addUnit();
                  },
                  child: const Icon(FIcons.plus),
                ),
              ),
          ],
        );
      },
    );
  }
}

class EditableFleatherCell extends StatefulWidget {
  final int id;
  final Function(Delta delta) saveData;
  final Delta initialDelta;
  final bool Function(VoidCallback saveFunction) checkAndSetActive;
  final void Function() removeActive;

  const EditableFleatherCell({
    super.key,
    required this.initialDelta,
    required this.saveData,
    required this.checkAndSetActive,
    required this.removeActive,
    required this.id,
  });

  @override
  State<EditableFleatherCell> createState() => EditableFleatherCellState();
}

class EditableFleatherCellState extends State<EditableFleatherCell> {
  FleatherController? controller;
  bool isEditing = false;
  late Delta currentDelta;

  @override
  void initState() {
    super.initState();
    currentDelta = widget.initialDelta;
  }

  @override
  void didUpdateWidget(covariant EditableFleatherCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentDelta = widget.initialDelta;
  }

  void save() {
    widget.removeActive();
    // final Delta delta = controller!.document.toDelta();
    currentDelta = controller!.document.toDelta();
    debugPrint(currentDelta.toString());
    widget.saveData(currentDelta);
    controller!.dispose();
    controller = null;
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      // controller = FleatherController(document: .fromDelta(widget.initialDelta));
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
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!widget.checkAndSetActive(save)) {
              return;
            }
            controller = FleatherController(
              document: .fromDelta(currentDelta)
            );
            setState(() {
              isEditing = true;
            });
          },
          child: IgnorePointer(child: FleatherViewer(delta: currentDelta)),
        );
      } else {
        return FleatherViewer(delta: currentDelta);
      }
    }
  }
}

class HoverInsertBox extends StatelessWidget {
  final VoidCallback onInsert;
  final int seamIndex;
  final ValueNotifier<int?> hoveredSeamNotifier;

  const HoverInsertBox({
    super.key,
    required this.onInsert,
    required this.seamIndex,
    required this.hoveredSeamNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => hoveredSeamNotifier.value = seamIndex,
      onExit: (_) {
        // Only clear it if a new box hasn't already claimed the state
        if (hoveredSeamNotifier.value == seamIndex) {
          hoveredSeamNotifier.value = null;
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onInsert,
        child: const SizedBox(height: 8, width: double.infinity),
      ),
    );
  }
}
