import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          notebookRepository: context.read<NotebookRepository>()),
      child: SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, SettingsState state) => Dialog(
          insetPadding: EdgeInsets.only(top: 56, bottom: 56, left: 256, right: 256),
          child: Padding(
            padding: const EdgeInsets.all(56.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 3, child: Text("App save location: ")),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 12,
                        children: [
                          Expanded(child: SelectableText(state.saveLocation)),
                          IconButton(
                              icon: Icon(Icons.folder),
                              onPressed: context.read<SettingsCubit>().changeSaveLocation),
                        ],
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  child: Text(
                    "Reset Settings",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => context.read<SettingsCubit>().resetSettings(context),
                ),
                OutlinedButton(
                  child: Text(
                    "Delete All Data",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => context.read<SettingsCubit>().deleteAppData(context),
                ),
                OutlinedButton(
                  child: Text("Reset and Delete Everything", style: TextStyle(color: Colors.red)),
                  onPressed: () => context.read<SettingsCubit>().completeReset(context),
                ),
              ],
            ),
          )),
    );
  }
}
