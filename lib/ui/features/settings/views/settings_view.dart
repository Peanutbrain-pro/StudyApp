import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/features/settings/cubits/settings_cubit.dart';

import '../../../../data/repositories/app_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(
        appRepository: context.read<AppRepository>(),
        notebookRepository: context.read<NotebookRepository>(),
      ),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
 const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) => Dialog(
        insetPadding: const EdgeInsets.only(top: 56, bottom: 56, left: 256, right: 256),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(flex: 3, child: Text("App save location: ")),
              //     Expanded(
              //       flex: 4,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         spacing: 12,
              //         children: [
              //           Expanded(child: SelectableText(state.saveLocation)),
              //           FButton.icon(
              //             variant: .outline,
              //             child: Icon(Icons.folder),
              //             onPress: () => context.read<SettingsCubit>().changeSaveLocation(context),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              FTile(
                title: const Text("Notebooks Save Location"),
                details: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400),
                child: SelectableText(state.saveLocation)),
                suffix: FButton.icon(
                  variant: .outline,
                  child: const Icon(FIcons.folder),
                  onPress: () => context.read<SettingsCubit>().changeSaveLocation(context),
                ),
              ),
              const SizedBox(height: 40),
              FButton(
                variant: .destructive,
                mainAxisSize: .min,
                child: const Text("Reset Settings"),
                onPress: () => context.read<SettingsCubit>().resetSettings(context),
              ),
              FButton(
                variant: .destructive,
                mainAxisSize: .min,
                child: const Text("Delete All Data"),
                onPress: () => context.read<SettingsCubit>().deleteAppData(context),
              ),
              FButton(
                variant: .destructive,
                mainAxisSize: .min,
                child: const Text("Reset and Delete Everything"),
                onPress: () => context.read<SettingsCubit>().completeReset(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
