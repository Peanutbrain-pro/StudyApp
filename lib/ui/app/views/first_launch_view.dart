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
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Welcome", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),),
          // Text(displayString),
          TextButton(onPressed: () {
            context.read<AppCubit>().setDefaultFirstLaunch();
          }, child: Text("Set default First launch settings."))
        ],
      ),),
    );
  }
}