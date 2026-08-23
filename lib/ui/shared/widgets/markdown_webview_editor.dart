import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MarkdownEditorController extends ChangeNotifier {
  InAppWebViewController? _webViewController;
  bool _isReady = false;
  String _currentMarkdown = '';

  bool get isReady => _isReady;
  String get markdown => _currentMarkdown;

  void attachWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  void markReady() {
    _isReady = true;
    notifyListeners();
  }

  void updateMarkdownFromWeb(String md) {
    _currentMarkdown = md;
    notifyListeners();
  }

  Future<void> setMarkdown(String markdown) async {
    _currentMarkdown = markdown;
    if (_webViewController != null && _isReady) {
      final jsonStr = jsonEncode(markdown);
      await _webViewController!.evaluateJavascript(source: 'window.setMarkdown($jsonStr);');
    }
  }

  Future<String> getMarkdown() async {
    if (_webViewController != null && _isReady) {
      final result = await _webViewController!.evaluateJavascript(source: 'window.getMarkdown();');
      if (result != null) {
        _currentMarkdown = result.toString();
      }
    }
    return _currentMarkdown;
  }

  Future<void> insertImage({
    required String url,
    required bool isNetwork,
    double? width,
    String? filename,
  }) async {
    if (_webViewController != null && _isReady) {
      final data = jsonEncode({
        'url': url,
        'isNetwork': isNetwork,
        'width': width ?? 300,
        'filename': filename ?? 'Image',
      });
      await _webViewController!.evaluateJavascript(source: 'window.insertImage($data);');
    }
  }

  Future<void> insertSource({
    required String filename,
    required String filetype,
    required String url,
  }) async {
    if (_webViewController != null && _isReady) {
      final data = jsonEncode({
        'filename': filename,
        'filetype': filetype,
        'url': url,
      });
      await _webViewController!.evaluateJavascript(source: 'window.insertSource($data);');
    }
  }

  Future<void> insertMath(String latex) async {
    if (_webViewController != null && _isReady) {
      final data = jsonEncode(latex);
      await _webViewController!.evaluateJavascript(source: 'window.insertMath($data);');
    }
  }
}

class MarkdownWebviewEditor extends StatefulWidget {
  final MarkdownEditorController controller;
  final String initialMarkdown;
  final ValueChanged<String>? onContentChanged;
  final void Function(String filename, String filetype, String url)? onSourceClicked;
  final void Function(String url)? onImageClicked;
  final VoidCallback? onEditorReady;

  const MarkdownWebviewEditor({
    super.key,
    required this.controller,
    this.initialMarkdown = '',
    this.onContentChanged,
    this.onSourceClicked,
    this.onImageClicked,
    this.onEditorReady,
  });

  @override
  State<MarkdownWebviewEditor> createState() => _MarkdownWebviewEditorState();
}

class _MarkdownWebviewEditorState extends State<MarkdownWebviewEditor> with AutomaticKeepAliveClientMixin {
  bool _editorLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return InAppWebView(
      initialFile: 'assets/milkdown_editor/index.html',
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        isInspectable: kDebugMode,
        supportZoom: false,
        useShouldOverrideUrlLoading: false,
        javaScriptEnabled: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
      ),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        return NavigationActionPolicy.ALLOW;
      },
      onWebViewCreated: (webViewController) {
        widget.controller.attachWebViewController(webViewController);

        // Handler when Milkdown is ready in JS
        webViewController.addJavaScriptHandler(
          handlerName: 'onEditorReady',
          callback: (args) {
            _editorLoaded = true;
            widget.controller.markReady();

            if (widget.initialMarkdown.isNotEmpty) {
              widget.controller.setMarkdown(widget.initialMarkdown);
            }
            widget.onEditorReady?.call();
          },
        );

        // Handler for content changes
        webViewController.addJavaScriptHandler(
          handlerName: 'onContentChange',
          callback: (args) {
            if (args.isNotEmpty && args[0] is String) {
              final markdown = args[0] as String;
              widget.controller.updateMarkdownFromWeb(markdown);
              widget.onContentChanged?.call(markdown);
            }
          },
        );

        // Handler for custom source embed clicks
        webViewController.addJavaScriptHandler(
          handlerName: 'onSourceClick',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final map = Map<String, dynamic>.from(args[0] as Map);
              final filename = (map['filename'] ?? '') as String;
              final filetype = (map['filetype'] ?? '') as String;
              final url = (map['url'] ?? '') as String;
              widget.onSourceClicked?.call(filename, filetype, url);
            }
          },
        );

        // Handler for image clicks
        webViewController.addJavaScriptHandler(
          handlerName: 'onImageClick',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final map = Map<String, dynamic>.from(args[0] as Map);
              final url = (map['url'] ?? '') as String;
              widget.onImageClicked?.call(url);
            }
          },
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (kDebugMode) {
          debugPrint('[Milkdown WebView Console] ${consoleMessage.message}');
        }
      },
    );
  }
}
