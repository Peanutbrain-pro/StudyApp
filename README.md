# StudyApp (WIP)

An AI-powered centralized note-taking and note-generation app for dealing with messy, unorganized notes.

---

## Prerequisites

* **[Flutter SDK](https://flutter.dev/docs/get-started/install)** (Stable channel)
* **[Node.js](https://nodejs.org/)** (v18+) & **[pnpm](https://pnpm.io/)** (or npm)

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

### 1. Clone the repository (with submodules)

```bash
git clone --recurse-submodules https://github.com/Peanutbrain-pro/StudyApp.git
cd StudyApp
```

> **Note for existing clones:** If you cloned without `--recurse-submodules`, initialize them with:
> ```bash
> git submodule update --init --recursive
> ```

### 2. Build the Web Editor Bundle

The in-app editor is built as a single-file bundle from the `editor` submodule:

```bash
cd editor
pnpm install
pnpm build
cd ..
```
*(This compiles and outputs the bundle into `assets/editor_bundle/index.html`)*.

### 3. Run the App

Fetch Flutter dependencies:
```bash
flutter pub get
```

Launch the app:
* **Linux:** `flutter run -d linux`
* **Windows:** `flutter run -d windows`

### (Optional) Code Generation

If you modify database tables or models:
```bash
dart run build_runner build --delete-conflicting-outputs
```
