import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';

class MilkdownFileEditorScreen extends StatefulWidget {
  final int notebookId;
  final String noteFilePath;
  final String sourcesDirectoryPath;
  final ValueChanged<String>? onContentChanged;

  const MilkdownFileEditorScreen({
    super.key,
    required this.notebookId,
    required this.noteFilePath,
    required this.sourcesDirectoryPath,
    this.onContentChanged,
  });

  @override
  State<MilkdownFileEditorScreen> createState() => MilkdownFileEditorScreenState();
}

class MilkdownFileEditorScreenState extends State<MilkdownFileEditorScreen> {
  InAppWebViewController? _webViewController;
  String _currentMarkdown = '';
  Timer? _debounceSaveTimer;
  bool _editorInitialized = false;
  String? _htmlFileUri;
  String? _lastAppliedFont;

  // Width settings: 0 means Full Width (100%)
  double _customWidth = 720.0;
  bool _isFullWidth = false;

  @override
  void initState() {
    super.initState();
    _loadExistingNoteContent();
    _loadSavedWidth();
    _locateHtmlBundle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyThemeToEditor();
    _checkAndApplyFont();
  }

  void _checkAndApplyFont() {
    try {
      final appCubit = context.watch<AppCubit>();
      if (appCubit.state is AppReady) {
        final font = (appCubit.state as AppReady).editorFont;
        if (font != _lastAppliedFont) {
          _lastAppliedFont = font;
          _applyFontToEditor(font);
        }
      }
    } catch (_) {}
  }

  void _applyFontToEditor([String? font]) {
    if (_webViewController == null) return;
    final fontToUse = font ?? _lastAppliedFont;
    if (fontToUse == null) return;
    _webViewController!.evaluateJavascript(
      source: 'if (window.AppBridge && window.AppBridge.setFont) { window.AppBridge.setFont(${jsonEncode(fontToUse)}); }',
    );
  }

  bool get _isAppDark {
    try {
      return context.theme.colors.brightness == Brightness.dark;
    } catch (_) {
      return Theme.of(context).brightness == Brightness.dark;
    }
  }

  void _applyThemeToEditor() {
    if (_webViewController == null) return;
    final isDark = _isAppDark;
    _webViewController!.evaluateJavascript(
      source: '''
        if (window.AppBridge && window.AppBridge.setTheme) {
          window.AppBridge.setTheme($isDark);
        } else {
          if ($isDark) {
            document.documentElement.classList.add('dark');
            document.documentElement.classList.remove('light');
            document.documentElement.setAttribute('data-theme', 'dark');
          } else {
            document.documentElement.classList.remove('dark');
            document.documentElement.classList.add('light');
            document.documentElement.setAttribute('data-theme', 'light');
          }
        }
      ''',
    );
  }

  Future<void> _loadExistingNoteContent() async {
    final file = File(widget.noteFilePath);
    if (await file.exists()) {
      _currentMarkdown = await file.readAsString();
    }
  }

  Future<void> _loadSavedWidth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWidth = prefs.getDouble('notebook_${widget.notebookId}_editor_width');
      final savedFull = prefs.getBool('notebook_${widget.notebookId}_editor_full_width');
      if (mounted) {
        setState(() {
          if (savedWidth != null) _customWidth = savedWidth;
          if (savedFull != null) _isFullWidth = savedFull;
        });
        _applyWidthToEditor();
      }
    } catch (_) {}
  }

  Future<void> _saveWidthPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('notebook_${widget.notebookId}_editor_width', _customWidth);
      await prefs.setBool('notebook_${widget.notebookId}_editor_full_width', _isFullWidth);
    } catch (_) {}
  }

  void _locateHtmlBundle() {
    String htmlPath;
    if (Platform.isWindows) {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      htmlPath = p.join(exeDir, 'data', 'flutter_assets', 'assets', 'editor_bundle', 'index.html');
      if (!File(htmlPath).existsSync()) {
        final currentDir = Directory.current.path;
        final devPath = p.join(currentDir, 'assets', 'editor_bundle', 'index.html');
        if (File(devPath).existsSync()) {
          htmlPath = devPath;
        }
      }
    } else {
      final currentDir = Directory.current.path;
      htmlPath = p.join(currentDir, 'assets', 'editor_bundle', 'index.html');
    }

    setState(() {
      _htmlFileUri = Uri.file(htmlPath).toString();
    });
  }

  @override
  void dispose() {
    _debounceSaveTimer?.cancel();
    _saveNoteFileSync(_currentMarkdown);
    super.dispose();
  }

  void _saveNoteFileSync(String markdown) {
    if (widget.noteFilePath.isNotEmpty) {
      try {
        final file = File(widget.noteFilePath);
        if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }
        file.writeAsStringSync(markdown);
      } catch (e) {
        debugPrint('Error writing note file synchronously: $e');
      }
    }
  }

  Future<void> _saveNoteFile(String markdown) async {
    if (widget.noteFilePath.isNotEmpty) {
      try {
        final file = File(widget.noteFilePath);
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsString(markdown);
      } catch (e) {
        debugPrint('Error writing note file: $e');
      }
    }
  }

  Future<void> _loadContentIntoEditor(String content) async {
    if (_webViewController == null) return;
    await _webViewController!.callAsyncJavaScript(
      functionBody: 'window.AppBridge.setContent(content);',
      arguments: {'content': content},
    );
  }

  void _onContentChanged(String newMarkdown) {
    _currentMarkdown = newMarkdown;
    widget.onContentChanged?.call(newMarkdown);
    _debounceSaveTimer?.cancel();
    _debounceSaveTimer = Timer(const Duration(milliseconds: 300), () => _saveNoteFile(newMarkdown));
  }

  /// Sends custom width to JavaScript
  void _applyWidthToEditor() {
    final effectiveWidth = _isFullWidth ? 0 : _customWidth.round();
    final paddingX = _isFullWidth ? 64 : 32;
    _webViewController?.evaluateJavascript(
      source: 'window.AppBridge.setCustomWidth($effectiveWidth, $paddingX);',
    );
  }

  void _openWidthAdjuster(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Document Width', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isFullWidth ? 'Full Width (100%)' : '${_customWidth.round()} px',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Row(
                          children: [
                            const Text('Full Width', style: TextStyle(fontSize: 12)),
                            Switch(
                              value: _isFullWidth,
                              onChanged: (val) {
                                setDialogState(() => _isFullWidth = val);
                                setState(() => _isFullWidth = val);
                                _applyWidthToEditor();
                                _saveWidthPreference();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!_isFullWidth) ...[
                      const SizedBox(height: 8),
                      Slider(
                        value: _customWidth,
                        min: 500,
                        max: 1600,
                        divisions: 110,
                        label: '${_customWidth.round()}px',
                        onChanged: (val) {
                          setDialogState(() => _customWidth = val);
                          setState(() => _customWidth = val);
                          _applyWidthToEditor();
                          _saveWidthPreference();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPresetChip('720px', 720, setDialogState),
                          _buildPresetChip('900px', 900, setDialogState),
                          _buildPresetChip('1100px', 1100, setDialogState),
                          _buildPresetChip('1400px', 1400, setDialogState),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip(String label, double width, StateSetter setDialogState) {
    final isSelected = !_isFullWidth && (_customWidth.round() == width.round());
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : null)),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
      onPressed: () {
        setDialogState(() {
          _isFullWidth = false;
          _customWidth = width;
        });
        setState(() {
          _isFullWidth = false;
          _customWidth = width;
        });
        _applyWidthToEditor();
        _saveWidthPreference();
      },
    );
  }

  // ─── Image handling: Copy to Sources/ & return file:/// URI ──────────────────

  Future<String> _handleImageBlobUpload(String fileName, String base64Data) async {
    if (base64Data.isEmpty) return '';
    try {
      final bytes = base64Decode(base64Data);
      final sourcesDir = Directory(widget.sourcesDirectoryPath);
      if (!await sourcesDir.exists()) {
        await sourcesDir.create(recursive: true);
      }

      final safeName = p.basename(fileName);
      final destFile = File(p.join(sourcesDir.path, safeName));
      await destFile.writeAsBytes(bytes);

      return Uri.file(destFile.path).toString();
    } catch (e) {
      debugPrint('Error writing image blob: $e');
      return '';
    }
  }

  Future<String> _handleImagePick() async {
    final result = await FilePicker.pickFile(type: FileType.image);
    if (result == null || result.path == null) return '';

    final sourcePath = result.path!;
    final sourcesDir = Directory(widget.sourcesDirectoryPath);
    if (!await sourcesDir.exists()) {
      await sourcesDir.create(recursive: true);
    }

    final fileName = p.basename(sourcePath);
    final destinationFile = File(p.join(sourcesDir.path, fileName));
    
    await File(sourcePath).copy(destinationFile.path);
    return Uri.file(destinationFile.path).toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_htmlFileUri == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final cardColor = context.theme.colors.card;

    return Container(
      color: cardColor,
      child: Stack(
        children: [
          // Webview Editor (fills whole container cleanly)
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_htmlFileUri!),
            ),
            initialSettings: InAppWebViewSettings(
              transparentBackground: false,
              supportZoom: false,
              isInspectable: kDebugMode,
              allowFileAccess: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
            ),
            onLoadStop: (controller, url) {
              _applyThemeToEditor();
              _applyFontToEditor();
            },
            onWebViewCreated: (controller) {
              _webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'onEditorReady',
                callback: (args) async {
                  _applyThemeToEditor();
                  _applyFontToEditor();
                  if (!_editorInitialized) {
                    _editorInitialized = true;
                    final file = File(widget.noteFilePath);
                    if (await file.exists()) {
                      _currentMarkdown = await file.readAsString();
                    }
                    if (_currentMarkdown.isNotEmpty) {
                      await _loadContentIntoEditor(_currentMarkdown);
                    }
                    _applyWidthToEditor();
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'onContentChanged',
                callback: (args) {
                  final markdown = args.first['markdown'] as String? ?? '';
                  _onContentChanged(markdown);
                },
              );

              // Single file upload via Base64 (from browser's 1st file picker)
              controller.addJavaScriptHandler(
                handlerName: 'onUploadImageBlob',
                callback: (args) async {
                  final argMap = (args.isNotEmpty && args.first is Map) ? args.first as Map : {};
                  final fileName = argMap['fileName'] as String? ?? 'img_${DateTime.now().millisecondsSinceEpoch}.png';
                  final base64String = argMap['base64'] as String? ?? '';
                  return await _handleImageBlobUpload(fileName, base64String);
                },
              );

              // Fallback
              controller.addJavaScriptHandler(
                handlerName: 'onPickLocalImagePath',
                callback: (args) async {
                  return await _handleImagePick();
                },
              );
            },
          ),

          // Minimal floating width button in top-right corner
          Positioned(
            top: 10,
            right: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openWidthAdjuster(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        _isFullWidth ? 'Full' : '${_customWidth.round()}px',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
