import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/features/settings/views/settings_view.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final OverlayPortalController overlayPortalController = OverlayPortalController();
  MainAppBar({super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return FHeader(
      title: Text(title),
      suffixes: [
        Row(
          spacing: 5,
          children: [
            if (context.watch<AppCubit>().state case AppReady s when s.requiresRestart)
              FButton(
                variant: .primary,
                child: Text("Please Restart"),
                onPress: context.read<AppCubit>().restartApp,
              ),
            SizedBox(width: 20),
            ...actions,
            FTooltip(
              tipAnchor: .topRight,
              childAnchor: .topLeft,
              tipBuilder: (context, _) => Text("Settings"),
              child: FButton.icon(
                variant: .ghost,
                onPress: () => showFDialog(
                  barrierLabel: "settings-barrier-label",
                  barrierDismissible: true,
                  context: context,
                  // transitionDuration: Duration(milliseconds: 20),
                  builder: (context, fdialogstyle, animation) => SettingsPage(),
                ),
                child: Icon(FIcons.menu),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
