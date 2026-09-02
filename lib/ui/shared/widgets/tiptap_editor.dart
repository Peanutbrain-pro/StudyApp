import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';

class TipTapSelectionState {
  final bool isBold;
  final bool isItalic;
  final bool isStrike;
  final bool isUnderline;
  final bool isCode;
  final bool isHighlight;
  final bool isHeading1;
  final bool isHeading2;
  final bool isHeading3;
  final bool isBulletList;
  final bool isOrderedList;
  final bool isTaskList;
  final bool isBlockquote;
  final bool isCodeBlock;
  final bool isTable;
  final bool canUndo;
  final bool canRedo;

  const TipTapSelectionState({
    this.isBold = false,
    this.isItalic = false,
    this.isStrike = false,
    this.isUnderline = false,
    this.isCode = false,
    this.isHighlight = false,
    this.isHeading1 = false,
    this.isHeading2 = false,
    this.isHeading3 = false,
    this.isBulletList = false,
    this.isOrderedList = false,
    this.isTaskList = false,
    this.isBlockquote = false,
    this.isCodeBlock = false,
    this.isTable = false,
    this.canUndo = false,
    this.canRedo = false,
  });

  factory TipTapSelectionState.fromMap(Map<String, dynamic> map) {
    return TipTapSelectionState(
      isBold: map['isBold'] == true,
      isItalic: map['isItalic'] == true,
      isStrike: map['isStrike'] == true,
      isUnderline: map['isUnderline'] == true,
      isCode: map['isCode'] == true,
      isHighlight: map['isHighlight'] == true,
      isHeading1: map['isHeading1'] == true,
      isHeading2: map['isHeading2'] == true,
      isHeading3: map['isHeading3'] == true,
      isBulletList: map['isBulletList'] == true,
      isOrderedList: map['isOrderedList'] == true,
      isTaskList: map['isTaskList'] == true,
      isBlockquote: map['isBlockquote'] == true,
      isCodeBlock: map['isCodeBlock'] == true,
      isTable: map['isTable'] == true,
      canUndo: map['canUndo'] == true,
      canRedo: map['canRedo'] == true,
    );
  }
}

class TipTapEditorController extends ChangeNotifier {
  InAppWebViewController? _webViewController;
  bool _isReady = false;
  String _currentMarkdown = '';
  TipTapSelectionState _selectionState = const TipTapSelectionState();

  bool get isReady => _isReady;
  String get markdown => _currentMarkdown;
  TipTapSelectionState get selectionState => _selectionState;

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

  void updateSelectionStateFromWeb(Map<String, dynamic> map) {
    _selectionState = TipTapSelectionState.fromMap(map);
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

  Future<String> getHTML() async {
    if (_webViewController != null && _isReady) {
      final result = await _webViewController!.evaluateJavascript(source: 'window.getHTML();');
      return result?.toString() ?? '';
    }
    return '';
  }

  Future<void> setHTML(String html) async {
    if (_webViewController != null && _isReady) {
      final jsonStr = jsonEncode(html);
      await _webViewController!.evaluateJavascript(source: 'window.setHTML($jsonStr);');
    }
  }

  Future<void> setTheme(String theme) async {
    if (_webViewController != null && _isReady) {
      final jsonStr = jsonEncode(theme);
      await _webViewController!.evaluateJavascript(source: 'window.setTheme($jsonStr);');
    }
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
    int? page,
    String? location,
  }) async {
    if (_webViewController != null && _isReady) {
      final map = <String, dynamic>{
        'filename': filename,
        'filetype': filetype,
        'url': url,
      };
      if (page != null) map['page'] = page;
      if (location != null && location.isNotEmpty) map['location'] = location;
      final data = jsonEncode(map);
      await _webViewController!.evaluateJavascript(source: 'window.insertSource($data);');
    }
  }

  Future<void> openSourceModal() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.openSourceModal();');
    }
  }

  Future<void> insertMath(String latex) async {
    if (_webViewController != null && _isReady) {
      final data = jsonEncode(latex);
      await _webViewController!.evaluateJavascript(source: 'window.insertMath($data);');
    }
  }

  Future<void> showMathModal() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.showMathModal();');
    }
  }

  Future<void> toggleBold() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleBold();');
    }
  }

  Future<void> toggleItalic() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleItalic();');
    }
  }

  Future<void> toggleStrike() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleStrike();');
    }
  }

  Future<void> toggleUnderline() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleUnderline();');
    }
  }

  Future<void> toggleCode() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleCode();');
    }
  }

  Future<void> toggleHighlight() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleHighlight();');
    }
  }

  Future<void> toggleHeading(int level) async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleHeading({ level: $level });');
    }
  }

  Future<void> toggleBulletList() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleBulletList();');
    }
  }

  Future<void> toggleOrderedList() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleOrderedList();');
    }
  }

  Future<void> toggleTaskList() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleTaskList();');
    }
  }

  Future<void> toggleBlockquote() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleBlockquote();');
    }
  }

  Future<void> toggleCodeBlock() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleCodeBlock();');
    }
  }

  Future<void> insertHorizontalRule() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.insertHorizontalRule();');
    }
  }

  // Table manipulation methods
  Future<void> insertTable({int rows = 3, int cols = 3}) async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.insertTable({ rows: $rows, cols: $cols });');
    }
  }

  Future<void> addRowAbove() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.addRowBefore();');
    }
  }

  Future<void> addRowBelow() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.addRowAfter();');
    }
  }

  Future<void> deleteRow() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.deleteRow();');
    }
  }

  Future<void> addColumnLeft() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.addColumnBefore();');
    }
  }

  Future<void> addColumnRight() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.addColumnAfter();');
    }
  }

  Future<void> deleteColumn() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.deleteColumn();');
    }
  }

  Future<void> deleteTable() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.deleteTable();');
    }
  }

  Future<void> toggleHeaderRow() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.toggleHeaderRow();');
    }
  }

  Future<void> undo() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.undo();');
    }
  }

  Future<void> redo() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.redo();');
    }
  }

  Future<void> focus() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.focusEditor();');
    }
  }

  Future<void> clear() async {
    if (_webViewController != null && _isReady) {
      await _webViewController!.evaluateJavascript(source: 'window.clear();');
    }
  }
}

class TipTapEditor extends StatefulWidget {
  final TipTapEditorController controller;
  final String initialMarkdown;
  final ValueChanged<String>? onContentChanged;
  final void Function(String filename, String filetype, String url, int? page, String? location)? onSourceClicked;
  final void Function(String url)? onImageClicked;
  final VoidCallback? onEditorReady;

  const TipTapEditor({
    super.key,
    required this.controller,
    this.initialMarkdown = '',
    this.onContentChanged,
    this.onSourceClicked,
    this.onImageClicked,
    this.onEditorReady,
  });

  @override
  State<TipTapEditor> createState() => _TipTapEditorState();
}

class _TipTapEditorState extends State<TipTapEditor> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTheme();
  }

  void _syncTheme() {
    final isDark = context.theme.colors.brightness == Brightness.dark;
    if (widget.controller.isReady) {
      widget.controller.setTheme(isDark ? 'dark' : 'light');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _syncTheme();

    return InAppWebView(
      initialFile: 'assets/tiptap_editor/index.html',
      initialSettings: InAppWebViewSettings(
        transparentBackground: false,
        isInspectable: kDebugMode,
        supportZoom: false,
        useShouldOverrideUrlLoading: false,
        javaScriptEnabled: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        disableContextMenu: true,
      ),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        return NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) {
        final currentDark = context.theme.colors.brightness == Brightness.dark;
        controller.evaluateJavascript(source: "window.setTheme('${currentDark ? 'dark' : 'light'}');");
      },
      onWebViewCreated: (webViewController) {
        widget.controller.attachWebViewController(webViewController);

        webViewController.addJavaScriptHandler(
          handlerName: 'onEditorReady',
          callback: (args) {
            widget.controller.markReady();
            final currentDark = context.theme.colors.brightness == Brightness.dark;
            widget.controller.setTheme(currentDark ? 'dark' : 'light');

            if (widget.initialMarkdown.isNotEmpty) {
              widget.controller.setMarkdown(widget.initialMarkdown);
            }
            widget.onEditorReady?.call();
          },
        );

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

        webViewController.addJavaScriptHandler(
          handlerName: 'onSelectionChange',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final map = Map<String, dynamic>.from(args[0] as Map);
              widget.controller.updateSelectionStateFromWeb(map);
            }
          },
        );

        webViewController.addJavaScriptHandler(
          handlerName: 'onSourceClick',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final map = Map<String, dynamic>.from(args[0] as Map);
              final filename = (map['filename'] ?? '') as String;
              final filetype = (map['filetype'] ?? '') as String;
              final url = (map['url'] ?? '') as String;
              final page = map['page'] != null ? int.tryParse(map['page'].toString()) : null;
              final location = map['location']?.toString();
              widget.onSourceClicked?.call(filename, filetype, url, page, location);
            }
          },
        );

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
          debugPrint('[TipTap WebView Console] ${consoleMessage.message}');
        }
      },
    );
  }
}
