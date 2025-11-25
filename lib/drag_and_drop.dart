import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:studyapp/document_preprocessing.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DragAndDropWidget extends StatefulWidget {
  final String outputPath;
  const DragAndDropWidget({super.key, required this.outputPath});

  @override
  State<DragAndDropWidget> createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends State<DragAndDropWidget> {
  late String outputPath;

  @override
  void initState() {
    super.initState();
    outputPath = widget.outputPath;
  }

  static const List<DataFormat<Object>> _allowedFormats = [
    Formats.plainText,
    Formats.plainTextFile,
    Formats.pdf,
    Formats.ppt,
    Formats.pptx,
    Formats.doc,
    Formats.docx,
    Formats.png,
    Formats.jpeg,
    Formats.heic,
    Formats.webp,
    Formats.xls,
    Formats.xlsx,
  ];
  Color _hoverColor = const Color.fromARGB(255, 231, 231, 231);

  // When dragging happens over this region
  FutureOr<DropOperation> onDropOver(DropOverEvent event) {
    setState(() {
      _hoverColor = const Color.fromARGB(255, 212, 212, 212);
    });
    if (event.session.items.every(
        (item) => _allowedFormats.any((format) => item.canProvide(format)))) {
      return DropOperation.copy;
    } else {
      return DropOperation.none;
    }
  }

  // When dragging leaves the region
  void onDropLeave(DropEvent event) {
    setState(() {
      _hoverColor = const Color.fromARGB(255, 231, 231, 231);
    });
  }

  // When user performs drop on the region
  Future<void> onPerformDrop(PerformDropEvent event) async {
    // List<String> filePaths = [];
    for (DropItem item in event.session.items) {
      final reader = item.dataReader!;
      if (reader.canProvide(Formats.pdf)) {
        reader.getValue(Formats.fileUri, (uri) {
          // renderPdfImage(uri!.toFilePath());
          print(
              "this is the output path sent to the splitPdf function: $widget.outputPath");
          splitPdf(
            [uri!.toFilePath()],
            outputLocation: widget.outputPath,
          );
          // filePaths.add(uri.toFilePath());
          // print(filePaths);
        });
      } else if (reader.canProvide(Formats.plainTextFile)) {
        debugPrint("file is text file");
      }
    }
    // print(filePaths);

    // if (filePaths.isNotEmpty) {
    //   splitPdf(filePaths);
    // }
  }

  // Image rendering
  // Future<void> renderPdfImage(String path) async {
  //   final document = await PdfDocument.openFile(path);
  //   final page = await document.getPage(1);
  //   final pageHeight = page.height;
  //   final pageWidth = page.width;

  //   final image = await page.render(
  //     height: pageHeight * 2,
  //     width: pageWidth * 2,
  //     format: PdfPageImageFormat.jpeg,
  //     quality: 65,
  //   );
  //
  //   await page.close();
  //   final filePath = Directory.current.path;
  //   final file = File("$filePath/rendered_image.jpeg");
  //   await file.writeAsBytes(image!.bytes);
  //   debugPrint("image saved at: $filePath");
  // }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: _allowedFormats,
      onDropOver: onDropOver,
      onDropLeave: onDropLeave,
      onPerformDrop: onPerformDrop,
      // child: Container(
      //   height: 100,
      //   color: _hoverColor,
      //   child: Center(child: Text("Drag & drop files here.")),
      // ),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(25),
            strokeWidth: 2,
            color: Colors.grey,
            dashPattern: [5, 3]),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: _hoverColor,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            height: 100,
            // color: _hoverColor,
            child: Center(child: Text("Drag & drop files here.")),
          ),
        ),
      ),
    );
  }
}
