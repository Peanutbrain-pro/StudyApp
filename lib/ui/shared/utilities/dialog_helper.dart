import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/adaptive_dialog.dart';
import 'package:studyapp/ui/shared/widgets/text_input_dialog.dart';

class DialogHelper {
  static Future<String?> getStringInput(
      BuildContext context,
      String title,
      String defaultValue,
      ) async {
    final String? result = await showFDialog<String>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogCtx, style, animation) {
        // Pass dialogCtx (the actual dialog route context), NOT the outer context
        return TextInputWidget(
          defaultValue: defaultValue,
          title: title,
          // dialogContext: dialogCtx,
        );
      },
    );

    return result;
  }

  static Future<bool> getConfirmation(
      BuildContext context,
      bool isDestructive,
      String title,
      String content,
      String confirmationText,
      ) async {
    final bool? out = await showFDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogCtx, style, animation) {
        return AdaptiveDialog(
          title: Text(title),
          body: Text(content),
          actions: [
            FButton(
              variant: isDestructive ? FButtonVariant.destructive : FButtonVariant.primary,
              onPress: () => Navigator.of(dialogCtx).pop(true),
              child: Text(confirmationText),
            ),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogCtx).pop(false),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );

    return out ?? false;
  }

  static Future<void> showError(
      BuildContext context,
      String title,
      String content,
      ) async {
    await showFDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogCtx, style, animation) {
        return AdaptiveDialog(
          title: Text(title),
          body: Text(content),
          actions: [
            FButton(
              variant: FButtonVariant.outline,
              child: const Text("OK"),
              onPress: () => Navigator.of(dialogCtx).pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAlert(
      BuildContext context,
      String title,
      String content,
      ) async {
    await showFDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogCtx, style, animation) {
        return AdaptiveDialog(
          title: Text(title),
          body: Text(content),
          actions: const [],
        );
      },
    );
  }
}
