import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:custom_interactive_viewer/custom_interactive_viewer.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart' hide Delta;
// import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/ui/features/notebooks/cubits/index_cubit.dart';
import 'package:studyapp/ui/shared/widgets/fleather_editor.dart';
import 'package:studyapp/ui/shared/widgets/fleather_toolbar.dart';
import 'package:studyapp/ui/shared/widgets/fleather_viewer.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => IndexCubit(), child: const IndexView());
  }
}

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
        return Stack(
          children: [
            CustomInteractiveViewer(
              interactionConfig: const .new(
                constrainBounds: true,

              ),
              // constrained: false,
              // noMouseDragScroll: false,
              // interactionEndFrictionCoefficient: 0.001,
              // allowNonCoveringScreenZoom: true,
              // minScale: 0.3,
              // maxScale: 3.5,
              // scaleFactor: 900,
              // panEnabled: _canPan,
              child: Container(
                width: 1200,
                constraints: const BoxConstraints(minHeight: 1000),
                decoration: BoxDecoration(
                  color: colors.card,
                  // color: Colors.white,
                  border: .all(width: 2, color: colors.border),
                ),
                child: BlocBuilder<IndexCubit, IndexState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Align(
                          alignment: .centerLeft,
                          child: Padding(
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
                        ),
                        IndexContent(
                          content: state.content,
                          checkAndSetActive: checkAndSetActive,
                          removeActive: removeActive,
                          noOfColumns: state.noOfColumns,
                          tableWidth: 1100,
                          headers: state.headers,
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
                    );
                  },
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
      },
    );
  }
}

class IndexContent extends StatefulWidget {
  final List<({int id, List<String> data})> content;
  final List<String> headers;
  // final List<List<String?>> content;
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
  });

  @override
  State<IndexContent> createState() => _IndexContentState();
}

class _IndexContentState extends State<IndexContent> {
  // late Map<int, TableColumnWidth> columnWidths;
  final tableScrollController = ScrollController();
  late List<double> columnWidths;
  final double minColumnWidth = 50;

  @override
  void initState() {
    super.initState();
    columnWidths = List.generate(widget.noOfColumns, (int index) {
      if (index == 1) return 400;
      return 200;
    });
    // columnWidths = {
    //   for (int i = 0; i < widget.noOfColumns; i++)
    //     i: i == 1 ? const FixedColumnWidth(400) : const FixedColumnWidth(200),
    // };
  }

  // Map<int, TableColumnWidth>? generateColumnWidth(int noOfColumns) {
  //   return .fromIterable(
  //     Iterable.generate(noOfColumns),
  //     key: (i) => i,
  //     value: (i) {
  //       if (i == 1) return const FixedColumnWidth(400);
  //       return const FlexColumnWidth(200);
  //     },
  //   );
  // }

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
            // A transparent placeholder block to maintain the header cell's minimum height
            // const Padding(
            //   padding: EdgeInsets.all(12.0),
            //   child: Visibility(
            //     visible: false,
            //     maintainSize: true,
            //     maintainAnimation: true,
            //     maintainState: true,
            //     child: Text("Spacer"),
            //   ),
            // ),
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
                    setState(() {
                      // Calculate new width ensuring it doesn't drop below the minimum
                      double newWidth = columnWidths[index] + details.delta.dx;
                      if (newWidth > minColumnWidth) {
                        columnWidths[index] = newWidth;
                      }
                    });
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
    return Scrollbar(
      controller: tableScrollController,
      child: SingleChildScrollView(
        controller: tableScrollController,
        scrollDirection: .horizontal,
        child: Table(
          columnWidths: {for (int i = 0; i < widget.noOfColumns; i++) i: FixedColumnWidth(columnWidths[i])},
          // columnWidths: generateColumnWidth(widget.noOfColumns),
          // columnWidths: const {0: FixedColumnWidth(250)},
          // This creates the clean lines between cells
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
                  // TableCell(
                  //   verticalAlignment: .fill,
                  //   child: Center(
                  //     child: SelectableText(
                  //       row.data[0],
                  //       style: context.theme.typography.xl.copyWith(
                  //         fontFamily: 'Source Sans 3',
                  //         fontWeight: .w500,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // ...generateHeaders(),
                  ...List<Widget>.generate(widget.noOfColumns, (int index) {
                    if (index >= row.data.length) {
                      return const TableCell(child: Text(""));
                    }
                    final List<dynamic> rawDelta = jsonDecode(row.data[index]);
                    final Delta dataDelta = Delta.fromJson(rawDelta);

                    return TableCell(
                      child: Padding(
                        // padding: const .only(top: 12, bottom: 12, right: 12, left: 24),
                        padding: const .all(12),
                        child: EditableFleatherCell(
                          initialDelta: dataDelta,
                          saveData: (delta) {
                            // context.read<IndexCubit>().editUnitDesc(row.id, jsonEncode(delta));
                            context.read<IndexCubit>().editUnitData(row.id, index, jsonEncode(delta));
                          },
                          checkAndSetActive: widget.checkAndSetActive,
                          removeActive: widget.removeActive,
                          id: row.id,
                        ),
                      ),
                    );
                  }, growable: false),
                ],
              );
            }),
          ],
        ),
      ),
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

  void save() {
    widget.removeActive();
    final Delta delta = controller!.document.toDelta();
    debugPrint(delta.toString());
    widget.saveData(delta);
    controller!.dispose();
    setState(() {
      isEditing = false;
    });
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
            offset: Offset(anchors.primaryAnchor.dx - 500, anchors.primaryAnchor.dy - 410),
            child: UnconstrainedBox(child: CustomFleatherToolbar(controller: controller!)),
          );
        },
        save: save,
      );
    } else {
      return SelectionArea(
        child: GestureDetector(
          onTap: () {
            if (!context.read<IndexCubit>().state.inEditMode) {
              return;
            }
            if (!widget.checkAndSetActive(save)) {
              return;
            }
            setState(() {
              isEditing = true;
            });
          },

          child: FleatherViewer(delta: widget.initialDelta),
        ),
      );
    }
  }
}
