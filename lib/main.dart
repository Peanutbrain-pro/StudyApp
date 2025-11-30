import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studyapp/gemini_service.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Gemini API key
  final _apiKey = Platform.environment['GEMINI_API_KEY'] ?? "no api key";
  final GeminiService newGeminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    newGeminiService.setApiKey(_apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Sources",
                  textScaler: TextScaler.linear(2),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 2),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Summary",
                  textScaler: TextScaler.linear(2),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
