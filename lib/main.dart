// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/router.dart';
// import 'package:studyapp/ui/shared/widgets/app_closing_overlay.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/app/cubits/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear();
  // exit(0);

  print("=== SHARED PREFERENCES DUMP ===");
  for (String key in prefs.getKeys()) {
    print('$key : ${prefs.get(key)}');
  }
  print("===============================");

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
        RepositoryProvider<NotebookRepository>(
          lazy: true,
          create: (BuildContext context) => NotebookRepository(
            db: context.read<AppDatabase>(),
            appSaveLocation: context.read<AppRepository>().getSaveLocation()!,
          ),
        ),
        // RepositoryProvider<NotebookRepository>(create: (BuildContext) => NotebookRepository()),
      ],
      child: BlocProvider(
        create: (BuildContext context) => AppCubit(
          // notebookRepository: context.read<NotebookRepository>(),
          appRepository: context.read<AppRepository>(),
        ),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget with WindowListener {
  final OverlayPortalController overlayPortalController = OverlayPortalController();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      title: 'Document summarizer',
      theme: FThemes.blue.light.desktop.toApproximateMaterialTheme(),
      darkTheme: FThemes.blue.dark.desktop.toApproximateMaterialTheme(),
      // darkTheme: FThemes.green.dark.desktop.toApproximateMaterialTheme(),
      builder: (_, child) {
        // 1. Detect if the system is in dark mode
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        
        windowManager.setBackgroundColor(isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5));
        windowManager.setBrightness(isDark ? Brightness.dark : Brightness.light);

        // 2. Dynamically assign the correct Forui theme variant
        final currentTheme = isDark ? FThemes.blue.dark.desktop : FThemes.blue.light.desktop;

        return FTheme(
          data: currentTheme,
          child: FTooltipGroup(child: child!),
        );
      },
      // home: BlocBuilder<AppCubit, AppState>(
      //   // listener: (BuildContext context, AppState state) {
      //   //   if (state is AppClosing) {
      //   //     overlayPortalController.show();
      //   //   } else {
      //   //     overlayPortalController.hide();
      //   //   }
      //   // },
      //   builder: (BuildContext context, AppState state) {
      //     switch (state) {
      //       case AppLoading():
      //         return CircularProgressIndicator();
      //       case AppFirstLaunch():
      //         return FirstLaunchView();
      //       // case AppClosing():
      //       case AppReady():
      //         return const HomePage();
      //     }
      //   },
      // ),
      routerConfig: router,
    );
  }
}
