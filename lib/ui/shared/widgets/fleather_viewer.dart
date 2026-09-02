import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class FleatherViewer extends StatefulWidget {
  final Delta delta;

  const FleatherViewer({super.key, required this.delta});

  @override
  State<FleatherViewer> createState() => _FleatherViewerState();
}

class _FleatherViewerState extends State<FleatherViewer> {
  late final FleatherController controller;

  @override
  void initState() {
    super.initState();
    controller = FleatherController(document: ParchmentDocument.fromDelta(widget.delta));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 12),
      child: FleatherEditor(controller: controller, readOnly: true, showCursor: false),
    );
  }
}
