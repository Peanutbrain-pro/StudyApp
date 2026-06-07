import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
// import 'package:forui/forui.dart';
import 'package:studyapp/ui/shared/widgets/text_input_dialog.dart';

class DialogHelper {
  static Future<String?> getStringInput(BuildContext context, String title, String defaultValue) async {
    String? result = await showFDialog<String>(
      barrierDismissible: true,
      context: context,
      builder: (dialogContext, fdialogStyle, animation) {
        return TextInputWidget(defaultValue: defaultValue, title: title, dialogContext: context);
      },
    );

    // textEditingController.dispose();
    return result;
  }

  static Future<bool> getConfirmation(
    BuildContext context,
    bool isDestructive,
    String title,
    String content,
    String confirmationText,
  ) async {
    bool? out = await showFDialog(
      barrierDismissible: true,
      context: context,
      builder: (context, fDialogStyle, animation) {
        return FDialog(
          direction: .horizontal,
          constraints: BoxConstraints(maxWidth: 500),
          title: Text(title),
          body: Text(content),
          actions: [
            FButton(
              variant: isDestructive ? .destructive : .primary,
              onPress: () => Navigator.pop(context, true),
              child: Text(confirmationText),
            ),
            FButton(variant: .outline, onPress: () => Navigator.pop(context, false), child: Text("Cancel")),
          ],
        );
      },
    );

    return out ?? false;
  }

  static Future<void> showError(BuildContext context, String title, String content) async {
    showFDialog(
      context: context,
      builder: (context, fDialogStyle, animation) {
        return FDialog(
          title: Text(title),
          body: Text(content),
          actions: [FButton(variant: .outline, child: Text("OK"), onPress: () => Navigator.of(context).pop())],
        );
      },
    );
  }

  static Future<void> showAlert(BuildContext context, String title, String content) async {
    showFDialog(
      context: context,
      builder: (context, fDialogStyle, animation) {
        return FDialog(title: Text(title), body: Text(content), actions: [],);
      },
    );
  }
}
