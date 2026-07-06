import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';
import 'package:studyapp/ui/router.dart';
import 'package:studyapp/ui/shared/widgets/window_title_bar.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/app/cubits/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    size: Size(1000, 700),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppRepository>(create: (BuildContext context) => AppRepository(prefs)),
        RepositoryProvider<AppDatabase>(
          lazy: true,
          create: (BuildContext context) {
            final saveLocation = context.read<AppRepository>().getSaveLocation();
            return AppDatabase(saveLocation!);
          },
        ),
        RepositoryProvider<UiPreferencesRepository>(
          lazy: true,
          create: (context) => UiPreferencesRepository(db: context.read<AppDatabase>()),
        ),
        RepositoryProvider<NotebookRepository>(
          lazy: true,
          create: (BuildContext context) => NotebookRepository(
            db: context.read<AppDatabase>(),
            appSaveLocation: context.read<AppRepository>().getSaveLocation()!,
          ),
        ),
      ],
      child: BlocProvider(
        create: (BuildContext context) => AppCubit(appRepository: context.read<AppRepository>()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      title: 'Document summarizer',
      theme: FThemes.blue.light.desktop.toApproximateMaterialTheme(),
      darkTheme: FThemes.blue.dark.desktop.toApproximateMaterialTheme(),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final currentTheme = isDark ? FThemes.blue.dark.desktop : FThemes.blue.light.desktop;

        return FTheme(
          data: currentTheme,
          child: Material(
            child: Column(
              children: [
                const CustomWindowTitleBar(),
                Expanded(child: FTooltipGroup(child: child!)),
              ],
            ),
          ),
        );
      },
      routerConfig: router,
    );
  }
}
