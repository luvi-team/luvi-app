# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Flutter application named `luvi_app` built with Flutter 3.35.4 and Dart 3.9.0. The project is configured for cross-platform development (iOS, Android, Web, macOS, Linux, Windows).

## Common Development Commands

### Setup and Dependencies
```bash
# Install dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Upgrade to latest compatible versions
flutter pub upgrade --major-versions

# Check for outdated packages
flutter pub outdated
```

### Development and Running
```bash
# Run the app on the default device
flutter run

# Run in debug mode (default)
flutter run --debug

# Run in profile mode (for performance testing)
flutter run --profile

# Run in release mode
flutter run --release

# Run on specific device (list devices first)
flutter devices
flutter run -d <device-id>

# Hot reload (during development)
# Press 'r' in the terminal while app is running

# Hot restart (during development)  
# Press 'R' in the terminal while app is running
```

### Building
```bash
# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Build for web
flutter build web

# Build for desktop platforms
flutter build macos
flutter build linux
flutter build windows
```

### Testing and Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix simple linting issues automatically
dart fix --apply
```

### Code Generation and Tools
```bash
# Generate code (if using code generators like json_serializable)
dart run build_runner build

# Watch for changes and regenerate code
dart run build_runner watch

# Clean generated files
dart run build_runner clean

# Clean build artifacts
flutter clean
```

## Project Structure

- `lib/` - Main source code directory
  - `main.dart` - Application entry point with MaterialApp setup
- `test/` - Unit and widget tests
  - `widget_test.dart` - Default widget test for the counter app
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` - Platform-specific configuration
- `pubspec.yaml` - Project configuration and dependencies
- `analysis_options.yaml` - Dart analyzer and linter configuration (uses flutter_lints)

## Development Notes

### Current State
This project is currently using the default Flutter template with a simple counter app. The main application logic is contained in `lib/main.dart` with:
- `MyApp` - Root MaterialApp widget
- `MyHomePage` - StatefulWidget with counter functionality

### Linting and Code Style
The project uses `flutter_lints` package for code analysis. The analyzer configuration is in `analysis_options.yaml` which includes the recommended Flutter lint rules.

### MCP Integration
The project has MCP (Model Context Protocol) integration enabled with GitHub server configured in `.claude/settings.local.json`.

### Multi-platform Support
The project is configured for all Flutter-supported platforms. Platform-specific configurations are in their respective directories.

## Testing

### Running Tests
- Use `flutter test` to run all tests
- The project includes a basic widget test in `test/widget_test.dart`
- Tests use the `flutter_test` framework

### Single Test Execution
```bash
# Run a specific test file
flutter test test/widget_test.dart

# Run tests matching a pattern
flutter test --name="Counter increments"
```

## Debugging

### Flutter Inspector
```bash
# Enable Flutter Inspector in supported IDEs
# Or use command line: 
flutter run --dart-define=FLUTTER_WEB_USE_SKIA=true  # For web debugging
```

### Device Debugging
```bash
# List connected devices
flutter devices

# Enable debugging on device
flutter run --verbose
```
