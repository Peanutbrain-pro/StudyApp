import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_win_floating/webview_win_floating.dart';

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
  late final WinWebViewController _webViewController;
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
    _webViewController = WinWebViewController();
    _setupController();
    _loadExistingNoteContent();
    _loadSavedWidth();
    _locateHtmlBundle();
  }

  void _setupController() {
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setNavigationDelegate(
      WinNavigationDelegate(
        onPageFinished: (url) {
          _applyThemeToEditor();
          _applyFontToEditor();
        },
      ),
    );
    _webViewController.addJavaScriptChannel(
      'FlutterBridge',
      onMessageReceived: (JavaScriptMessage message) {
        _handleMessageFromEditor(message.message);
      },
    );
  }

  void _handleMessageFromEditor(String rawMessage) async {
    try {
      final data = jsonDecode(rawMessage);
      if (data is! Map) return;

      final type = data['type'] as String?;
      final content = data['content'];

      switch (type) {
        case 'ready':
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
          break;
        case 'auto_save':
          if (content is String) {
            _onContentChanged(content);
          }
          break;
        case 'upload_image':
          if (content is Map) {
            final fileName = content['fileName'] as String? ?? 'image.png';
            final base64Str = content['base64'] as String? ?? '';
            _handleImageBlobUpload(fileName, base64Str);
          }
          break;
        case 'pick_image':
          _handleImagePick();
          break;
        case 'error':
          debugPrint('[Milkdown] Editor error: $content');
          break;
      }
    } catch (e) {
      debugPrint('[Milkdown] Error parsing message from editor: $e');
    }
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
    final fontToUse = font ?? _lastAppliedFont;
    if (fontToUse == null) return;
    final fontJson = jsonEncode(fontToUse);
    _webViewController.runJavaScript('''
      (() => {
        if (window.setEditorFont) {
          window.setEditorFont('default', $fontJson);
          window.setEditorFont('title', $fontJson);
        }
        if (window.AppBridge && window.AppBridge.setFont) {
          window.AppBridge.setFont($fontJson);
        }
      })();
    ''');
  }

  bool get _isAppDark {
    try {
      return context.theme.colors.brightness == Brightness.dark;
    } catch (_) {
      return Theme.of(context).brightness == Brightness.dark;
    }
  }

  void _applyThemeToEditor() {
    final isDark = _isAppDark;
    _webViewController.runJavaScript('''
      (() => {
        const isDark = $isDark;
        if (isDark) {
          document.documentElement.classList.add('dark');
          document.documentElement.classList.remove('light');
          document.documentElement.setAttribute('data-theme', 'dark');
        } else {
          document.documentElement.classList.remove('dark');
          document.documentElement.classList.add('light');
          document.documentElement.setAttribute('data-theme', 'light');
        }
      })();
    ''');
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
    } else if (Platform.isLinux) {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final bundlePath = p.join(exeDir, 'data', 'flutter_assets', 'assets', 'editor_bundle', 'index.html');
      if (File(bundlePath).existsSync()) {
        htmlPath = bundlePath;
      } else {
        final devPath = p.join(Directory.current.path, 'assets', 'editor_bundle', 'index.html');
        htmlPath = devPath;
      }
    } else {
      final currentDir = Directory.current.path;
      htmlPath = p.join(currentDir, 'assets', 'editor_bundle', 'index.html');
    }

    final fileUri = Uri.file(htmlPath).toString();
    setState(() {
      _htmlFileUri = fileUri;
    });
    _webViewController.loadRequest(Uri.parse(fileUri));
  }

  @override
  void dispose() {
    _debounceSaveTimer?.cancel();
    _saveNoteFileSync(_currentMarkdown);
    _webViewController.dispose();
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
    final contentJson = jsonEncode(content);
    await _webViewController.runJavaScript('''
      (() => {
        if (window.setEditorContent) {
          window.setEditorContent($contentJson);
        } else if (window.AppBridge && window.AppBridge.setContent) {
          window.AppBridge.setContent($contentJson);
        }
      })();
    ''');
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
    final maxWidthVal = effectiveWidth > 0 ? '${effectiveWidth}px' : '100%';
    _webViewController.runJavaScript('''
      (() => {
        if (window.AppBridge && window.AppBridge.setCustomWidth) {
          window.AppBridge.setCustomWidth($effectiveWidth, $paddingX);
        }
        const el = document.querySelector('.milkdown');
        if (el) {
          el.style.maxWidth = '$maxWidthVal';
          el.style.margin = '0 auto';
          el.style.paddingLeft = '${paddingX}px';
          el.style.paddingRight = '${paddingX}px';
        }
      })();
    ''');
  }

  Future<void> _openWidthAdjuster(BuildContext context) async {
    // Hide floating webview while dialog is open so dialog is not obscured
    await _webViewController.setVisibility(false);
    if (!context.mounted) return;

    await showDialog(
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
              actions: [TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close'))],
            );
          },
        );
      },
    );

    if (mounted) {
      await _webViewController.setVisibility(true);
    }
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
    final borderColor = context.theme.colors.border;

    return Container(
      color: cardColor,
      child: Column(
        children: [
          // Header bar with Document Width control (placed outside floating webview so it's never covered)
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(bottom: BorderSide(color: borderColor, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openWidthAdjuster(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
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
              ],
            ),
          ),
          // Webview Editor fills remaining height cleanly
          Expanded(
            child: WinWebViewWidget(
              controller: _webViewController,
            ),
          ),
        ],
      ),
    );
  }
}
