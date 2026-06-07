import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';

class FirstLaunchView extends StatelessWidget {
  // final SharedPreferences prefs;
  const FirstLaunchView({super.key});

  @override
  Widget build(BuildContext context) {
    // final String displayString = prefs.getKeys()
    // .map((key) => "$key: ${prefs.get(key)}")
    // .join("\n");

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            // Text(displayString),
            Container(
              decoration:
                  BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(15)),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 20,
                  children: [
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(flex: 3, child: Text("App save location: ")),
                        Expanded(
                          flex: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 12,
                            children: [
                              Expanded(
                                  child: FutureBuilder(
                                    future: context.read<AppCubit>().getDefaultAppSaveLocation(),
                                    builder: (context, asyncSnapshot) {
                                      return SelectableText(asyncSnapshot.data!);
                                    }
                                  )),
                              IconButton(
                                  icon: const Icon(Icons.folder),
                                  onPressed: context.read<AppCubit>().changeSaveLocation),
                            ],
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)))
                      ),
                      child: const Text("Done"),
                      onPressed: () => context.read<AppCubit>().onFirstConfigFinished(),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  context.read<AppCubit>().setDefaultFirstLaunch();
                },
                child: const Text("Set default First launch settings."))
          ],
        ),
      ),
    );
  }
}
