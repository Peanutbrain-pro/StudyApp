import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/features/settings/views/settings_view.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;
  final List<Widget> prefixes;
  final OverlayPortalController overlayPortalController = OverlayPortalController();
  MainAppBar({super.key, required this.title, required this.actions, this.prefixes = const []});

  @override
  Widget build(BuildContext context) {
    return FHeader(
      title: Row(
        spacing: 10,
        mainAxisSize: .min,
        children: [
          if (prefixes.isNotEmpty) Row(children: prefixes),
          Expanded(child: title),
        ],
      ),
      suffixes: [
        Row(
          spacing: 5,
          children: [
            if (context.watch<AppCubit>().state case AppReady s when s.requiresRestart)
              FButton(
                variant: .primary,
                onPress: context.read<AppCubit>().restartApp,
                child: const Text("Please Restart"),
              ),
            const SizedBox(width: 20),
            ...actions,
            FTooltip(
              tipAnchor: .topRight,
              childAnchor: .topLeft,
              tipBuilder: (context, _) => const Text("Settings"),
              child: FButton.icon(
                variant: .ghost,
                onPress: () => showFDialog(
                  barrierLabel: "settings-barrier-label",
                  barrierDismissible: true,
                  context: context,
                  builder: (context, fdialogstyle, animation) => const SettingsPage(),
                ),
                child: const Icon(FLucideIcons.menu),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
