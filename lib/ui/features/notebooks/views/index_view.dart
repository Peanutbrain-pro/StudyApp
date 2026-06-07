import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart' hide Delta;
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:studyapp/ui/features/notebooks/cubits/index_cubit.dart';
import 'package:studyapp/ui/shared/widgets/fleather_editor.dart';
import 'package:studyapp/ui/shared/widgets/fleather_toolbar.dart';
import 'package:studyapp/ui/shared/widgets/fleather_viewer.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => IndexCubit(), child: IndexView());
  }
}

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return BlocBuilder<IndexCubit, IndexState>(
      builder: (context, state) {
        return Stack(
          children: [
            InteractiveViewer2(
              constrained: false,
              noMouseDragScroll: false,
              interactionEndFrictionCoefficient: 0.001,
              allowNonCoveringScreenZoom: true,
              minScale: 0.3,
              maxScale: 3.5,
              scaleFactor: 900,
              panEnabled: true,

              child: Container(
                width: 1200,
                constraints: BoxConstraints(minHeight: 1000),
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
                        IndexContent(content: state.content),
                        Align(
                          alignment: .centerRight,
                          child: FButton(
                            mainAxisSize: .min,
                            onPress: () {
                              debugPrint(state.content.toString());
                            },
                            child: Text("Print state"),
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
                            .base(.boxDelta(color: Colors.green)),
                            .exact({.hovered}, .boxDelta(color: Colors.green[700])),
                            .match({
                              .disabled,
                            }, .boxDelta(color: Colors.green.withAlpha((0.4 * 255).toInt()))),
                          ]),
                        ),
                        size: .lg,
                        onPress: () {
                          context.read<IndexCubit>().toggleEditMode();
                        },
                        prefix: Icon(FIcons.check, size: 20),
                        child: Text("Done", style: .new(fontSize: 18)),
                      )
                    : FButton(
                        size: .lg,
                        onPress: () {
                          context.read<IndexCubit>().toggleEditMode();
                        },
                        prefix: Icon(FIcons.pencilLine, size: 20),
                        child: Text("Edit", style: .new(fontSize: 18)),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class IndexContent extends StatelessWidget {
  final List<({int id, List<String> data})> content;
  // final List<List<String?>> content;

  const IndexContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1050),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(250)},
        // This creates the clean lines between cells
        border: TableBorder(
          top: BorderSide(color: colors.border, width: 2),
          right: BorderSide(color: colors.border, width: 2),
          bottom: BorderSide(color: colors.border, width: 2),
          left: BorderSide(color: colors.border, width: 2),
          horizontalInside: BorderSide(color: colors.border.withAlpha(120), width: 2),
          verticalInside: BorderSide(color: colors.border.withAlpha(120), width: 2),
          borderRadius: .circular(10),
        ),
        children: content.map((row) {
          final List<dynamic> rawDelta = jsonDecode(row.data[1]);
          final Delta descDelta = Delta.fromJson(rawDelta);

          return TableRow(
            children: [
              TableCell(
                verticalAlignment: .fill,
                child: Center(
                  child: SelectableText(
                    row.data[0],
                    style: context.theme.typography.xl.copyWith(
                      fontFamily: 'Source Sans 3',
                      fontWeight: .w500,
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  // padding: const .only(top: 12, bottom: 12, right: 12, left: 24),
                  padding: const .all(5),
                  child: EditableFleatherCell(
                    initialDelta: descDelta,
                    saveData: (delta) {
                      context.read<IndexCubit>().editUnitDesc(row.id, jsonEncode(delta));
                    },
                  ),
                  // child: SelectableText(
                  //   row.data.length > 1 ? (row.data[1].isEmpty ? "" : row.data[1]) : "",
                  //   // row.data[1],
                  //   style: context.theme.typography.md.copyWith(fontFamily: 'Source Sans 3'),
                  // ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class EditableFleatherCell extends StatefulWidget {
  final Function(Delta delta) saveData;
  final Delta initialDelta;
  const EditableFleatherCell({super.key, required this.initialDelta, required this.saveData});
  @override
  State<EditableFleatherCell> createState() => EditableFleatherCellState();
}

class EditableFleatherCellState extends State<EditableFleatherCell> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final controller = FleatherController(document: .fromDelta(widget.initialDelta));
      return CustomFleatherEditor(
        controller: controller,
        contextMenuBuilder: (context, editorState) {
          final anchors = editorState.contextMenuAnchors;
          print(anchors.primaryAnchor);
          return Transform.translate(
            offset: Offset(anchors.primaryAnchor.dx - 500, anchors.primaryAnchor.dy - 100),
            child: CustomFleatherToolbar(controller: controller),
          );
        },
        save: () {
          final Delta delta = controller.document.toDelta();
          debugPrint(delta.toString());
          widget.saveData(delta);
          controller.dispose();
          setState(() {
            isEditing = false;
          });
        },
      );
    } else {
      return SelectionArea(
        child: GestureDetector(
          onTap: () {
            if (!context.read<IndexCubit>().state.inEditMode) {
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
