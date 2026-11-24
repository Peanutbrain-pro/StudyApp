# StudyApp (WIP)

A desktop-first study companion, notebook manager, and document workspace built with Flutter.

---

## Features

- **Desktop-First UX**: Native custom title bar, keyboard shortcuts, and clean window management for Linux and Windows.
- **Rich Document Notes**: 100% native Flutter editor powered by `super_editor` with rich text formatting (headings, lists, blockquotes, code blocks), clipboard paste (screenshots, copied image files), and resizable, alignable images (Left, Center, Right, custom width presets, corner drag handles).
- **Multi-Column Index Grid**: Interactive table with inline `super_text_field` rich text editing, auto-expanding heights, integrated formatting toolbars, and auto-save.
- **Cross-Platform Typography**: Guaranteed consistency across platforms with bundled `Inter` and `JetBrains Mono` fonts, plus high-performance native system font discovery (`fc-list` on Linux, Registry on Windows).
- **Local SQLite Persistence**: Fully offline, high-performance local database powered by [Drift](https://drift.simonbinder.eu/) with file-backed Markdown synchronization.
- **Forui Design System**: Dark-mode-first aesthetic with refined tokens, responsive scaling, and zero webview bloat.

---

## Prerequisites

* **[Flutter SDK](https://flutter.dev/docs/get-started/install)** (Stable channel, Flutter 3.29+)

### Desktop Toolchain

* **Linux:** Standard C++ build tools and GTK development libraries:
  ```bash
  # Debian / Ubuntu:
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
  # Arch Linux:
  sudo pacman -S clang cmake ninja pkgconf gtk3
  # Fedora:
  sudo dnf install clang cmake ninja-build pkgconf-pkg-config gtk3-devel
  ```
* **Windows:** [Visual Studio](https://visualstudio.microsoft.com/downloads/) (Community edition is fine) with the **"Desktop development with C++"** workload installed.

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Peanutbrain-pro/StudyApp.git
cd StudyApp
```

### 2. Fetch Dependencies

```bash
flutter pub get
```

### 3. Run the App

* **Linux:**
  ```bash
  flutter run -d linux
  ```
* **Windows:**
  ```bash
  flutter run -d windows
  ```

---

## Database & Code Generation

If you modify Drift database tables (`lib/data/database/tables/`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Testing & Verification

Run automated tests:
```bash
flutter test
```

Run static analysis:
```bash
dart analyze
```
