import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

class WindowsButtonListener extends WindowListener {
  final ValueNotifier<bool> isMaximized = ValueNotifier(false);

  @override
  void onWindowMaximize() => isMaximized.value = true;

  @override
  void onWindowUnmaximize() => isMaximized.value = false;

  @override
  void onWindowRestore() async {
    isMaximized.value = await windowManager.isMaximized();
  }

  void dispose() => isMaximized.dispose();
}

class CustomWindowTitleBar extends StatefulWidget {
  const CustomWindowTitleBar({super.key});

  @override
  State<CustomWindowTitleBar> createState() => _CustomWindowTitleBarState();
}

class _CustomWindowTitleBarState extends State<CustomWindowTitleBar> {
  late final WindowsButtonListener windowsButtonListener;
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowsButtonListener = WindowsButtonListener();
    windowManager.addListener(windowsButtonListener);
    windowsButtonListener.isMaximized.addListener(_isMaximizedChanged);
    windowManager.isMaximized().then((v) {
      if (mounted) setState(() => isMaximized = v);
    });
  }

  void _isMaximizedChanged() {
    if (mounted) {
      setState(() => isMaximized = windowsButtonListener.isMaximized.value);
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(windowsButtonListener);
    windowsButtonListener.isMaximized.removeListener(_isMaximizedChanged);
    windowsButtonListener.dispose();
    super.dispose();
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

                  // Image.asset(
                  //   'assets/pdf_icon.png',
                  //   width: 16,
                  //   height: 16,
                  //   errorBuilder: (context, error, stackTrace) =>
                  //       Icon(Icons.book, size: 16, color: isDark ? Colors.white70 : Colors.black87),
                  // ),
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
            onPressed: () async {
              await windowManager.minimize();
            },
          ),
          if (isMaximized)
            WindowCaptionButton.unmaximize(
              brightness: brightness,
              onPressed: () async {
                await windowManager.unmaximize();
              },
            )
          else
            WindowCaptionButton.maximize(brightness: brightness, onPressed: () async => await windowManager.maximize()),
          WindowCaptionButton.close(brightness: brightness, onPressed: () async => await windowManager.close()),
        ],
      ),
    );
  }
}
