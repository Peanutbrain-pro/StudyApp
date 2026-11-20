import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';

class FirstLaunchView extends StatelessWidget {
  const FirstLaunchView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Welcome",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "App save location: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.foreground,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: FutureBuilder(
                                    future: context.read<AppCubit>().getDefaultAppSaveLocation(),
                                    builder: (context, asyncSnapshot) {
                                      return SelectableText(
                                        asyncSnapshot.data ?? "",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.mutedForeground,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FButton.icon(
                                  variant: .outline,
                                  onPress: context.read<AppCubit>().changeSaveLocation,
                                  child: const Icon(FLucideIcons.folder, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FButton(
                        variant: .primary,
                        onPress: () => context.read<AppCubit>().onFirstConfigFinished(),
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FButton(
              variant: .ghost,
              onPress: () {
                context.read<AppCubit>().setDefaultFirstLaunch();
              },
              child: Text(
                "Set default First launch settings.",
                style: TextStyle(color: colors.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
