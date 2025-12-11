import 'package:flutter/material.dart';
import 'package:studyapp/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document summarizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff519872)),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const MyHomePage(),
    );
  }
}
