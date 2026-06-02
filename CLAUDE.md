# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Get dependencies
flutter pub get

# Run the app (select device interactively, or specify with -d)
flutter run

# Run on a specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android (emulator or device)
flutter run -d ios             # iOS (simulator)

# Static analysis / lint
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build for specific platforms
flutter build apk              # Android APK
flutter build ios              # iOS
flutter build web              # Web
flutter build windows          # Windows EXE
flutter build macos            # macOS
flutter build linux            # Linux

# Check outdated dependencies
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

## Environment

- **Flutter** 3.44.1 (stable channel, revision 924134a44c)
- **Dart** 3.12.1
- **Linter**: `package:flutter_lints/flutter.yaml` (v6.0.0)

## Architecture

This is a standard Flutter project targeting **six platforms**: Android, iOS, Linux, macOS, Web, Windows.

- `lib/main.dart` — App entry point. Currently contains the default Flutter counter app with `MyApp` (root `StatelessWidget` using `MaterialApp`) and `MyHomePage` (stateful counter page).
- `test/` — Standard Flutter test directory using `flutter_test` and `WidgetTester`.
- Assets go under the project root (or platform-specific subdirectories like `assets/`) and are declared in `pubspec.yaml` under the `flutter:` section.
- Platform-specific build files and configurations live in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`.
