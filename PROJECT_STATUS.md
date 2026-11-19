# Project Status and Issues Report

**Last Updated:** 2026-11-20  
**Branch:** `develop` (Tracking `origin/develop`)

---

## 1. Executive Summary

**studyapp** is a Flutter desktop application for notebook management, rich markdown note-taking, and past year question (PYQ) tracking.

All compile-time blockers and critical issues have been resolved:
1. **Milkdown Crepe Editor Migration Completed:** `MilkdownEditor.dart` renamed to `milkdown_editor.dart` and migrated to `webview_win_floating` (`WinWebViewController` & `WinWebViewWidget`) with full communication over the `FlutterBridge` channel.
2. **Linux Font Support Implemented:** `FontService` now queries `fc-list : family` on Linux desktops with zero extra dependencies and graceful fallback.
3. **Compilation & Warning Cleanup:**
   - 0 Errors, 0 Warnings across the entire project in `flutter analyze`.
   - `note_repository.dart` unused imports and fields eliminated.
   - `colors.dart` and `icons.dart` `const` constructor warnings fixed.
   - Decoupled Material UI (`package:material_ui`) active across all views.

---

## 2. Recent Progress & Changes Completed

### A. Milkdown Crepe Webview Migration (`lib/ui/shared/widgets/milkdown_editor.dart`)
- Refactored away from `flutter_inappwebview` to `webview_win_floating` (`WinWebViewController` / `WinWebViewWidget`).
- Replaced non-standard `file_names` (`MilkdownEditor.dart` -> `milkdown_editor.dart`) and updated all import call sites (`notes_view.dart`).
- Configured bi-directional bridge communication via `FlutterBridge`:
  - `ready` -> loads document content, applies current app theme, font family, and saved editor width.
  - `auto_save` -> debounced note content persistence.
  - `upload_image` / `pick_image` -> saves images locally to notebook sources folder.
- Configured dialog overlay safety:
  - Invokes `_webViewController.setVisibility(false)` when opening dialogs (e.g. document width tuner) and restores visibility on close to prevent native HWND/WebKit z-index clipping.
  - Placed the width tuning header button in a dedicated top bar above the floating webview.

### B. Linux Font Service (`lib/services/font_service.dart`)
- Added native Linux desktop font querying via `fc-list : family` using `Process.run`.
- Automatically parses and deduplicates system, package, and user font families (`/usr/share/fonts`, `~/.local/share/fonts`, `~/.fonts`).
- Falls back to `defaultFallbackFonts` if `fc-list` is unavailable or errors.

### C. Dependency & Code Cleanup
- Cleaned unused imports and fields in `lib/data/repositories/note_repository.dart`.
- Converted `Color(...)` instantiations in `lib/theme/colors.dart` to `const Color(...)` and unified `FIcons` in `lib/theme/icons.dart`.
- Ensured all pub dependencies are cross-platform and support both Windows and Linux.

---

## 3. Platform Compatibility Summary

| Package / Module | Windows | Linux | Implementation Details |
|---|---|---|---|
| **`webview_win_floating`** | ✅ Supported | ✅ Supported | WebView2 on Windows, WebKit2GTK on Linux. |
| **`window_manager`** | ✅ Supported | ✅ Supported | Native window control on both. |
| **`drift` / `drift_flutter`** | ✅ Supported | ✅ Supported | Sqlite3 across all desktop platforms. |
| **`FontService`** | ✅ Supported | ✅ Supported | Windows Registry query on Windows; `fc-list` on Linux. |
| **`file_picker`** | ✅ Supported | ✅ Supported | Win32 on Windows; Zenity/Portal on Linux. |
| **`path_provider`** | ✅ Supported | ✅ Supported | AppData on Windows; XDG on Linux. |
| **`restart_app`** | ✅ Supported | ✅ Supported | Native desktop executable restart. |

---

## 4. Current Static Analysis Status

`flutter analyze` reports **0 errors** and **0 warnings**.
Remaining items are non-blocking informational `avoid_print` statements in legacy logging call sites.
