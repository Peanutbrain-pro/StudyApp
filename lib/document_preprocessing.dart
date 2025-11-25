import 'dart:io';
import 'package:flutter/material.dart';

const String outputLocation = "C:\\Users\\KIIT0001\\Desktop";

Future<void> splitPdf(List<String> filePaths,
    {String outputLocation = outputLocation}) async {
  // final file = File(filePath);
  // final pdfBytes = await file.readAsBytes();
  // final pdfDoc = pw.Document.load(PdfDocumentParser())
  debugPrint("This is running");
  filePaths.insert(0, outputLocation);
  print(filePaths);

  try {
    var result = await Process.run(
        '${Directory.current.path}\\scripts\\dist\\splitPdf.exe', filePaths);
    print(result.stdout);
    if (result.exitCode == 0) {
      debugPrint("${result.stdout}");
    } else {
      debugPrint("Error. ${result.stderr}");
    }
  } catch (e) {
    debugPrint("Failed to run EXE: $e");
  }
}
