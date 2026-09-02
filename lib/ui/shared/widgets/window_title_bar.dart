import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class CustomWindowTitleBar extends StatefulWidget {
  const CustomWindowTitleBar({super.key});

  @override
  State<CustomWindowTitleBar> createState() => _CustomWindowTitleBarState();
}

class _CustomWindowTitleBarState extends State<CustomWindowTitleBar> with WindowListener {
  bool _isMaximized = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isMaximized = _prefs?.getBool('window_is_maximized') ?? false;
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    _isMaximized = true;
    _prefs?.setBool('window_is_maximized', true);
    if (mounted) setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    _isMaximized = false;
    _prefs?.setBool('window_is_maximized', false);
    _saveNormalBounds();
    if (mounted) setState(() {});
  }

  @override
  void onWindowResized() {
    if (!_isMaximized) _saveNormalBounds();
  }

  @override
  void onWindowMoved() {
    if (!_isMaximized) _saveNormalBounds();
  }

  Future<void> _saveNormalBounds() async {
    if (_isMaximized || _prefs == null) return;
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();
    if (position.dx < -10000 || position.dy < -10000) return;
    if (size.width < 960 || size.height < 450) return;

    await _prefs!.setDouble('window_width', size.width);
    await _prefs!.setDouble('window_height', size.height);
    await _prefs!.setDouble('window_x', position.dx);
    await _prefs!.setDouble('window_y', position.dy);
  }

  Future<void> _toggleMaximize() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  const FlutterLogo(size: 16),
                  const SizedBox(width: 12),
                  Text(
                    'StudyApp',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          WindowCaptionButton.minimize(
            brightness: brightness,
            onPressed: () async => await windowManager.minimize(),
          ),
          if (_isMaximized)
            WindowCaptionButton.unmaximize(
              brightness: brightness,
              onPressed: _toggleMaximize,
            )
          else
            WindowCaptionButton.maximize(
              brightness: brightness,
              onPressed: _toggleMaximize,
            ),
          WindowCaptionButton.close(
            brightness: brightness,
            onPressed: () async => await windowManager.close(),
          ),
        ],
      ),
    );
  }
}
