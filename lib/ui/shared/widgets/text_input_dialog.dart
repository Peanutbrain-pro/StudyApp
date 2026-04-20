import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  String title;
  String default_value;
  BuildContext dialogContext;
  TextInputWidget({
    super.key,
    required this.default_value,
    required this.title,
    required this.dialogContext
  });

  final TextEditingController textEditingController = TextEditingController();
  // textEditingController.text = default_value;

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}
class _TextInputWidgetState extends State<TextInputWidget> {
  
  @override
  void dispose() {
    super.dispose();
    widget.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.textEditingController.text = widget.default_value;

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: widget.textEditingController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          Navigator.pop(widget.dialogContext, widget.textEditingController.text);
        }
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(widget.dialogContext),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(widget.dialogContext, widget.textEditingController.text),
          child: Text("OK"),
        )
      ],
    );
  }
}
