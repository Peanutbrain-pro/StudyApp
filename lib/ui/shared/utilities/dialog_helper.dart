import 'package:flutter/material.dart';
import 'package:studyapp/ui/shared/widgets/text_input_dialog.dart';

class DialogHelper {
  static Future<String> getStringInput(BuildContext context, String title, String default_value) async {
    String? result = await showDialog<String>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext dialogContext) {
        return TextInputWidget(default_value: default_value, title: title, dialogContext: context,);
      },
    );

    // textEditingController.dispose();
    return result ?? default_value;
  }

  static Future<bool> getConfirmation(
      BuildContext context, String title, String content, String confirmation_text) async {
    bool? out = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            constraints: BoxConstraints(maxWidth: 500),
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmation_text),
              ),
            ],
          );
        });

    return out?? false;
  }

  static Future<void> showError(BuildContext context, String title, String content) async {
    showDialog(context: context, builder: (BuildContext context) { 
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop(),)
        ],
      );
     });
  }
}
