import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/app/views/first_launch_view.dart';
import 'package:studyapp/ui/features/home/views/home_view.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/app/cubits/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear();

  print("=== SHARED PREFERENCES DUMP ===");
  for (String key in prefs.getKeys()) {
    print('$key : ${prefs.get(key)}');
  }
  print("===============================");

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppRepository>(
          create: (BuildContext context) => AppRepository(prefs),
        ),
        RepositoryProvider<AppDatabase>(
          lazy: true,
          create: (BuildContext context) {
            final saveLocation =
                context.read<AppRepository>().getSaveLocation();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Document summarizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff519872)),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: BlocBuilder<AppCubit, AppState>(
        builder: (BuildContext context, state) {
          switch (state) {
            case AppLoading():
              return CircularProgressIndicator();
            case AppFirstLaunch():
              return FirstLaunchView();
            case AppReady():
              return HomePage();
          }
        },
      ),
    );
  }
}
