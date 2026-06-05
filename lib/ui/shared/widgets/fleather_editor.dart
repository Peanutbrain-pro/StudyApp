import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFleatherEditor extends StatefulWidget {
  final FleatherController controller;
  final Function save;
  const CustomFleatherEditor({super.key, required this.controller, required this.save});

  @override
  State<CustomFleatherEditor> createState() => _CustomFleatherEditorState();
}

class _CustomFleatherEditorState extends State<CustomFleatherEditor> {
  late final FocusNode _editorFocusNode;

  @override
  void initState() {
    super.initState();

    _editorFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyRepeatEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          return KeyEventResult.handled;
        }

        // if ((event is KeyDownEvent) &&
        //     event.logicalKey == LogicalKeyboardKey.enter) {
        //   return _handleEnterKey();
        // }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyE, control: true): () {
          widget.controller.formatSelection(ParchmentAttribute.center);
        },
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): () {
          widget.controller.formatSelection(ParchmentAttribute.left);
        },
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () {
          widget.controller.formatSelection(ParchmentAttribute.right);
        },
        const SingleActivator(LogicalKeyboardKey.keyJ, control: true): () {
          widget.controller.formatSelection(ParchmentAttribute.justify);
        },
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          widget.save();
        },
      },
      child: Container(
        decoration: BoxDecoration(
          border: .all(color: Colors.blue, width: 2),
          borderRadius: .circular(8),
        ),
        child: FleatherEditor(controller: widget.controller, focusNode: _editorFocusNode),
      ),
    );
  }
}
