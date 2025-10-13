---
description: Repository Information Overview
alwaysApply: true
---

# Personal Homepage Information

## Summary
A modern Flutter web application that functions as a personal browser homepage with Google Search, bookmarks management, task tracking, customizable backgrounds, and embedded mini-games. The app is designed with a clean, minimalist UI and offers offline-first functionality.

## Structure
- **lib/**: Core application code
  - **core/**: Models, providers, storage, and utilities
  - **pages/**: Main application screens
  - **games/**: Mini-game implementations
  - **widgets/**: Reusable UI components
- **assets/**: Images and wallpapers
- **test/**: Widget testing
- **web/**, **android/**, **ios/**, **macos/**, **linux/**, **windows/**: Platform-specific code

## Language & Runtime
**Language**: Dart
**Version**: SDK ^3.9.2
**Framework**: Flutter 3.22+
**Build System**: Flutter build system
**Package Manager**: pub (Flutter/Dart)

## Dependencies
**Main Dependencies**:
- **UI & Theming**: flutter_animate (^4.5.0), google_fonts (^6.1.0)
- **State Management**: provider (^6.1.1)
- **Storage**: hive (^2.2.3), hive_flutter (^1.1.0), shared_preferences (^2.2.2)
- **URL & File Handling**: url_launcher (^6.2.3), file_picker (^6.1.1)
- **Game Engine**: flame (^1.15.0)
- **Utilities**: intl (^0.19.0), uuid (^4.3.3), html (^0.15.4)

**Development Dependencies**:
- flutter_test, flutter_lints (^3.0.0)
- hive_generator (^2.0.1), build_runner (^2.4.8)

## Build & Installation
```bash
# Get dependencies
flutter pub get

# Run in development mode
flutter run -d chrome

# Build for production
flutter build web
```

## Main Components
- **Main Entry Point**: lib/main.dart
- **Storage Service**: lib/core/storage/hive_service.dart
- **State Management**: Provider pattern with multiple providers
  - ThemeProvider: Theme mode management
  - BackgroundProvider: Background image management
  - BookmarksProvider: Bookmark data management
  - TasksProvider: Task data management
- **Main Pages**:
  - HomePage: Search functionality and clock
  - BookmarksPage: Bookmark management
  - TasksPage: Task management
  - GamesPage: Mini-games launcher
  - SettingsPage: App configuration

## Features
- **Bookmarks Management**: CRUD operations, import/export, organization
- **Task Management**: Create, edit, delete tasks with due dates and categories
- **Background Customization**: URL, local image, preset wallpapers, gradient
- **Theme Support**: Light, dark, and system theme modes
- **Mini-Games**: Snake, Flappy Bird, Tic-Tac-Toe, Memory Match
- **Offline-First**: Local storage with Hive
- **Responsive Design**: Adapts to different screen sizes

## Testing
**Framework**: flutter_test
**Test Location**: test/widget_test.dart
**Run Command**:
```bash
flutter test
```

## Data Storage
**Storage Solution**: Hive
**Box Structure**:
- bookmarks_box: Stores bookmark data
- tasks_box: Stores task data
- settings_box: Stores app settings (theme, background)
**Initialization**: HiveService.init() called in main() before app starts