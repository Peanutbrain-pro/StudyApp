import 'package:flutter/material.dart';
import 'package:studyapp/ui/features/settings/views/settings_view.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const MainAppBar({super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              ...actions,
            
              IconButton(icon: Icon(Icons.menu), onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SettingsPage()
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(56);
}
