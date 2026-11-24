# Project Status and Architecture Report

**Last Updated:** 2026-11-24  
**Branch:** `main` (Default branch)

---

## 1. Executive Summary

**StudyApp** is a desktop-first study companion, notebook manager, and document workspace built with Flutter.

The codebase has transitioned away from webview-based editors and legacy text engines to a **100% native Flutter editor architecture** powered by `super_editor` and `super_text_field`.

---

## 2. Key Architecture & Features

### A. Native Document Editor (`NotesView` & `super_editor`)
- Replaced webview-based editors with native `super_editor` pinned to upstream `stable`.
- **Theme & Overlays**: Styled with `forui` color tokens (`FThemeData`) and theme-aware custom carets that suppress blinking carets on non-text elements.
- **Image Management**:
  - Interactive corner drag handles for real-time resizing.
  - Floating `FPopover` toolbar for width presets (25%, 50%, 75%, 100%), alignment (Left, Center, Right), and deletion.
  - Zero-layout-shift popover positioning directly over the text layer.
  - URL hash fragment architecture (`#left`, `#right`) ensuring alignment persists directly through Markdown serialization on disk.
  - Safe RegEx cleaning that preserves filenames containing `#`.
- **Clipboard & Media**: Native clipboard pasteboard support (`pasteboard: ^0.6.2`) for immediate pasting of screenshots, image files, and URLs.
- **Keyboard Shortcuts & Reactions**: History undo/redo (`Ctrl+Z`, `Ctrl+Shift+Z` / `Ctrl+Y`), headings (`Ctrl+Alt+1..3`), quote/code conversions, and trailing paragraph guarantees.

### B. Inline Table Editor (`IndexView` & `super_text_field`)
- Replaced legacy editors with `SuperTextField`-backed inline table cells.
- **Dual-Mode Architecture**:
  - *Viewer Mode*: Renders lightweight `Text.rich(computeInlineSpan(...))` with zero controllers, focus nodes, or tickers for smooth 60–120 FPS panning and zooming in `InteractiveViewer2`.
  - *Editor Mode*: Sharp, flush container (`BorderRadius.zero`) with integrated top formatting toolbar and auto-expanding line height (`minLines: _lineCount`).
- **Markdown Serialization**: Lightweight line-by-line Markdown serializer and deserializer (`cell_content_serializer.dart`) that prevents multi-line formatting tokens from leaking.
- **Auto-Save & Safe Disposal**: 600ms debounced persistence to SQLite, blur/done auto-commit, and deferred microtask disposal to prevent active ticker assertions.

### C. Cross-Platform Desktop Typography & Theming
- Bundled offline `Inter` and `JetBrains Mono` variable fonts in `assets/fonts/`.
- High-performance asynchronous system font discovery (`FontService` with `fc-list` on Linux and Registry on Windows).
- Desktop typography tokens with clamped text scaling to ensure uniform sizing across Wayland, X11, and Windows.
- Independent Index document canvas scaling inside `InteractiveViewer2`.

---

## 3. Platform Compatibility Summary

| Package / Module | Windows | Linux | Implementation Details |
|---|---|---|---|
| **`super_editor`** | ✅ Supported | ✅ Supported | 100% native Flutter document editor; zero webview dependencies. |
| **`super_text_field`** | ✅ Supported | ✅ Supported | Native rich text editing in Index table cells. |
| **`drift` / `drift_flutter`** | ✅ Supported | ✅ Supported | High-performance SQLite database. |
| **`window_manager`** | ✅ Supported | ✅ Supported | Custom frameless window title bar with native drag and window controls. |
| **`FontService`** | ✅ Supported | ✅ Supported | Windows Registry query on Windows; `fc-list` on Linux with lazy rasterization. |
| **`file_picker`** | ✅ Supported | ✅ Supported | `FilePicker.pickDirectory()` returning system paths via `uri.toFilePath()`. |
| **`pasteboard`** | ✅ Supported | ✅ Supported | Direct clipboard image pasting from OS desktop clipboard. |

---

## 4. Quality & Verification Status

- **Automated Tests**: All unit tests passing (`test/services/`, `test/widgets/`).
- **Static Analysis**: `dart analyze` reports **0 errors** and **0 warnings**.
- **Desktop Builds**: Verified debug build on Linux (`flutter build linux --debug`).
