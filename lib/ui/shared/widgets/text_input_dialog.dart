import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TextInputWidget extends StatefulWidget {
  final String title;
  final String default_value;
  final BuildContext dialogContext;
  TextInputWidget({super.key, required this.default_value, required this.title, required this.dialogContext});

  // final TextEditingController textEditingController = TextEditingController();
  // textEditingController.text = default_value;

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    // widget.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.default_value;
    // FTextFieldControl fTextFieldControl = FTextFieldControl.managed(initial: TextEditingValue(text: widget.default_value));

    return FDialog(
      direction: .horizontal,
      title: Padding(
        padding: const .only(top: 15, bottom: 10, left: 5),
        child: Text(widget.title),
      ),
      body: FTextField(
        control: .managed(
          controller: textEditingController,
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmit: (value) {
          Navigator.pop(widget.dialogContext, value);
        },
      ),
      actions: [
        FButton(variant: .primary, onPress: () => Navigator.pop(widget.dialogContext, textEditingController.text), child: Text("OK")),
        FButton(variant: .outline, onPress: () => Navigator.pop(widget.dialogContext), child: Text("Cancel")),
      ],
    );
  }
}
