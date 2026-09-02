import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/index_repository.dart';
import 'package:studyapp/data/repositories/note_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';
import 'package:studyapp/services/font_service.dart';
import 'package:studyapp/theme/theme.dart';
import 'package:studyapp/ui/router.dart';
import 'package:studyapp/ui/shared/widgets/window_title_bar.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/app/cubits/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  FontService.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool wasMaximized = prefs.getBool('window_is_maximized') ?? false;
  final double? width = prefs.getDouble('window_width');
  final double? height = prefs.getDouble('window_height');
  final double? x = prefs.getDouble('window_x');
  final double? y = prefs.getDouble('window_y');

  final bool hasValidPosition = x != null && y != null && x > -10000 && y > -10000;
  final bool hasValidSize = width != null && height != null && width >= 960 && height >= 450;

  final WindowOptions windowOptions = WindowOptions(
    size: hasValidSize ? Size(width, height) : const Size(1000, 700),
    center: !hasValidPosition,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(960, 450));
    if (hasValidPosition) {
      await windowManager.setPosition(Offset(x, y));
    }
    if (wasMaximized) {
      await windowManager.maximize();
    }
    await windowManager.show();
    await windowManager.focus();
  });

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
        RepositoryProvider<NoteRepository>(
          lazy: true,
          create: (context) => NoteRepository(db: context.read<AppDatabase>()),
        ),
        RepositoryProvider<IndexRepository>(
          lazy: true,
          create: (context) => IndexRepository(db: context.read<AppDatabase>()),
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
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) {
        if (previous is AppReady && current is AppReady) {
          return previous.appFont != current.appFont;
        }
        return true;
      },
      builder: (context, state) {
        final String appFont = (state is AppReady) ? state.appFont : 'System Default';
        final String? effectiveFont = (appFont.isNotEmpty && appFont != 'System Default')
            ? appFont
            : null;

        final FThemeData customLightTheme = getLightTheme(fontFamily: effectiveFont);
        final FThemeData customDarkTheme = getDarkTheme(fontFamily: effectiveFont);

        ThemeData lightMat = customLightTheme.toApproximateMaterialTheme();
        ThemeData darkMat = customDarkTheme.toApproximateMaterialTheme();

        if (effectiveFont != null) {
          lightMat = lightMat.copyWith(
            textTheme: lightMat.textTheme.apply(fontFamily: effectiveFont),
          );
          darkMat = darkMat.copyWith(
            textTheme: darkMat.textTheme.apply(fontFamily: effectiveFont),
          );
        }

        return MaterialApp.router(
          supportedLocales: FLocalizations.supportedLocales,
          localizationsDelegates: const [
            ...FLocalizations.localizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Document summarizer',
          theme: lightMat,
          darkTheme: darkMat,
          themeMode: ThemeMode.system,
          builder: (context, child) {
            final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
            final currentTheme = isDark ? customDarkTheme : customLightTheme;

            return FTheme(
              data: currentTheme,
              child: Material(
                color: currentTheme.colors.background,
                child: Column(
                  children: [
                    const CustomWindowTitleBar(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            );
          },
          routerConfig: router,
        );
      },
    );
  }
}
