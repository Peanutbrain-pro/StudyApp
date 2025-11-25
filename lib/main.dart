import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studyapp/gemini_service.dart';
import 'drag_and_drop.dart';

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

  final TextEditingController _textController = TextEditingController();
  String _saveLocation = "";
  String geminiResponse = "This is where you will get response from gemini";

  @override
  void initState() {
    super.initState();
    _getDocumentsDirectory();
    newGeminiService.setApiKey(_apiKey);
  }

  Future<void> _getDocumentsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      setState(() {
        _saveLocation = '${directory.path}\\StudyApp';
        _textController.text = _saveLocation;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _pickSaveLocation() async {
    try {
      String? directory =
          await FilePicker.platform.getDirectoryPath(lockParentWindow: true);
      setState(() {
        if (directory != null) {
          _saveLocation = '$directory\\StudyApp';
        } else {
          debugPrint("Couldn't pick folder.");
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Platform.environment.forEach((key, value) {
    //   print('$key: $value');
    // });
    debugPrint(_apiKey);
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Storage Location: "),
                  SizedBox(
                    width: 400,
                    child: Text(
                      _saveLocation,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: _pickSaveLocation,
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              DragAndDropWidget(outputPath: _saveLocation),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: _summarizePdfs,
                child: Text("Summarize and create note",
                    style: TextStyle(fontSize: 16)),
              ),
              SizedBox(
                height: 20,
              ),
              Text(geminiResponse)
            ],
          ),
        ),
      ),
    );
  }

  void _summarizePdfs() async {
    List<String> filePaths = [];
    Directory saveLocation = Directory(_saveLocation);
    await for (FileSystemEntity entity
        in saveLocation.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        filePaths.add(entity.path);
      }
    }

    debugPrint("List of PDFs: ");
    for (String filePath in filePaths) {
      debugPrint(filePath);
    }

    // Uploading all files to gemini
    List<String> newfilePaths = [];
    for (String filePath in filePaths) {
      String? temp = await newGeminiService.uploadFile(
          filePath, lookupMimeType(filePath)!);
      newfilePaths.add(temp!);
    }

    String? response = await newGeminiService.getResponse(
        "Summarize the given pdfs, two sentences for each pdf max.",
        fileUris: newfilePaths);

    debugPrint(response);
    setState(() {
      geminiResponse = response!;
    });
  }
}
