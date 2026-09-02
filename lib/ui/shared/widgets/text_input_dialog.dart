import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/adaptive_dialog.dart';

class TextInputWidget extends StatefulWidget {
  final String title;
  final String defaultValue;
  final BuildContext? dialogContext;
  const TextInputWidget({
    super.key,
    required this.defaultValue,
    required this.title,
    this.dialogContext,
  });

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.defaultValue);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, String? value) {
    final navContext = widget.dialogContext ?? context;
    if (navContext.mounted) {
      Navigator.pop(navContext, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 10, left: 5),
        child: Text(widget.title),
      ),
      body: ExcludeSemantics(
        child: FTextField(
          control: .managed(
            controller: textEditingController,
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmit: (value) => _submit(context, value),
        ),
      ),
      actions: [
        FButton(
          variant: .primary,
          onPress: () => _submit(context, textEditingController.text),
          child: const Text("OK"),
        ),
        FButton(
          variant: .outline,
          onPress: () => _submit(context, null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
