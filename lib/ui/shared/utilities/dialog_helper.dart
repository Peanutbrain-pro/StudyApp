import 'package:flutter/material.dart';

class DialogHelper {
  // final TextEditingController _textEditingController = TextEditingController();

  static Future<String> getStringInput(BuildContext context, String title, String default_value) async {
    final TextEditingController _textEditingController = TextEditingController();
    _textEditingController.text = default_value;

    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _textEditingController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                  context, _textEditingController.text),
              child: Text("OK"),
            )
          ],
        );
      },
    );

    return result?? default_value;
  }
}