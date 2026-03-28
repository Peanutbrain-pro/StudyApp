import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/app/views/first_launch_view.dart';
import 'package:studyapp/ui/features/home/views/home_view.dart';

import 'ui/app/cubits/app_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        RepositoryProvider(
            create: (BuildContext context) => AppRepository(prefs)),
        RepositoryProvider(
            create: (BuildContext context) => NotebookRepository()),
      ],
      child: BlocProvider(
        create: (BuildContext context) => AppCubit(
            appRepository: context.read<AppRepository>(),
            notebookRepository: context.read<NotebookRepository>()),
        child: MyApp(prefs),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp(this.prefs, {super.key});

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
              return FirstLaunchView(prefs: prefs);
            case AppReady():
              return HomePage();
          }
        },
      ),
    );
  }
}
