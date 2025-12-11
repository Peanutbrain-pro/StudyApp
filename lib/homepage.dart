import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studyapp/gemini_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Gemini API key
  final _apiKey = Platform.environment['GEMINI_API_KEY'] ?? "no api key";
  final GeminiService newGeminiService = GeminiService();

  bool _isHoveringOnApp = false;
  bool _isHoveringOnDropRegion = false;

  String tempDirectory = '';
  List<String> filePaths = [];

  @override
  void initState() {
    super.initState();
    newGeminiService.setApiKey(_apiKey);
    getTempDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: DropTarget(
              onDragEntered: (DropEventDetails _) {
                debugPrint("Drag entered");
                setState(() {
                  _isHoveringOnApp = true;
                });
              },
              onDragExited: (DropEventDetails _) {
                debugPrint("Drag exited");
                setState(() {
                  _isHoveringOnApp = false;
                });
              },
              child: Stack(
                alignment: AlignmentGeometry.bottomCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Sources",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 22),
                        ),
                      ),
                      Expanded(child: SourceWindow()),
                      SizedBox(height: 100)
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 32.0, right: 32, bottom: 24),
                    child: DropTarget(
                      onDragDone: (details) {},
                      onDragEntered: (_) {
                        setState(() {
                          _isHoveringOnDropRegion = true;
                        });
                      },
                      onDragExited: (_) {
                        setState(() {
                          _isHoveringOnDropRegion = false;
                        });
                      },
                      child: AnimatedContainer(
                        curve: Curves.easeOutQuad,
                        duration: Duration(milliseconds: 100),
                        height: _isHoveringOnApp ? 180 : 60,
                        width: _isHoveringOnApp ? 2000 : 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _isHoveringOnDropRegion
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(width: 1, color: Colors.grey),
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: _isHoveringOnApp
                              ? Text("Drop your files here",
                                  style: TextStyle(
                                    color: _isHoveringOnDropRegion
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                  ))
                              : IconButton(
                                  icon: Icon(Icons.add),
                                  style: ButtonStyle(
                                      minimumSize:
                                          WidgetStatePropertyAll(Size(60, 60)),
                                      shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)))),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  onPressed: () {},
                                ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void getTempDirectory() async {
    final Directory sysTempDirectory = await getTemporaryDirectory();
    final tempDirectoryPath =
        path.join(sysTempDirectory.path, 'studyapp_pdf_files');

    final appTempDirectory = Directory(tempDirectoryPath);
    if (!await appTempDirectory.exists()) {
      await appTempDirectory.create(recursive: true);
    }

    setState(() {
      tempDirectory = tempDirectoryPath;
    });
  }
}

class SourceWindow extends StatefulWidget {
  const SourceWindow({super.key});
  @override
  State<SourceWindow> createState() => _SourceWindowState();
}

class _SourceWindowState extends State<SourceWindow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 32, right: 32, bottom: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          spacing: 10,
          children: [
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
            Container(color: Colors.blue, height: 80),
          ],
        ),
      ),
    );
  }
}
