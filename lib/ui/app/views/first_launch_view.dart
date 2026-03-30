import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';

class FirstLaunchView extends StatelessWidget {
  final SharedPreferences prefs;
  const FirstLaunchView({super.key, required this.prefs});
 
  @override
  Widget build(BuildContext context) {
    final String displayString = prefs.getKeys()
    .map((key) => "$key: ${prefs.get(key)}")
    .join("\n");

    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("This is the first launch screen", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),),
          Text(displayString),
          TextButton(onPressed: () {
            context.read<AppCubit>().setDefaultFirstLaunch();
          }, child: Text("Set default First launch settings."))
        ],
      ),),
    );
  }
}