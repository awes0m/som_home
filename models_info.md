# API Documentation

## Core Models

### Bookmark Model

```dart
class Bookmark {
  final String id;              // Unique identifier (UUID)
  String title;                 // Display title
  String url;                   // Website URL
  String? folder;               // Optional folder name
  bool isFavorite;              // Favorite flag
  DateTime createdAt;           // Creation timestamp

  // Constructor
  Bookmark({
    String? id,
    required this.title,
    required this.url,
    this.folder,
    this.isFavorite = false,
    DateTime? createdAt,
  });

  // Serialization
  Map<String, dynamic> toJson();
  factory Bookmark.fromJson(Map<String, dynamic> json);
}
```

### Task Model

```dart
class Task {
  final String id;              // Unique identifier (UUID)
  String title;                 // Task title
  String? notes;                // Optional notes
  String? category;             // Optional category
  DateTime? dueDate;            // Optional due date
  bool isCompleted;             // Completion status
  DateTime createdAt;           // Creation timestamp

  // Constructor
  Task({
    String? id,
    required this.title,
    this.notes,
    this.category,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  });

  // Serialization
  Map<String, dynamic> toJson();
  factory Task.fromJson(Map<String, dynamic> json);
}
```

## Providers (State Management)

### ThemeProvider

Manages application theme preferences.

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode;
  
  // Set theme mode (light, dark, system)
  void setThemeMode(ThemeMode mode);
}
```

**Usage:**
```dart
// Get theme mode
final themeMode = Provider.of<ThemeProvider>(context).themeMode;

// Set theme mode
Provider.of<ThemeProvider>(context, listen: false)
    .setThemeMode(ThemeMode.dark);
```

### BackgroundProvider

Manages background image customization.

```dart
class BackgroundProvider extends ChangeNotifier {
  String? get backgroundUrl;
  String? get backgroundType;
  
  // Set background from URL or base64
  void setBackground(String? url, String type);
  
  // Clear background (use default)
  void clearBackground();
}
```

**Background Types:**
- `'url'` - Network image URL
- `'local'` - Base64 encoded local image
- `'preset'` - Preset wallpaper
- `'default'` - Default gradient

**Usage:**
```dart
// Set background
Provider.of<BackgroundProvider>(context, listen: false)
    .setBackground('https://example.com/image.jpg', 'url');

// Clear background
Provider.of<BackgroundProvider>(context, listen: false)
    .clearBackground();
```

### BookmarksProvider

Manages bookmark operations and storage.

```dart
class BookmarksProvider extends ChangeNotifier {
  List<Bookmark> get bookmarks;           // All bookmarks
  List<Bookmark> get favorites;           // Favorite bookmarks only
  List<String> get folders;               // List of folder names
  
  // CRUD Operations
  void addBookmark(Bookmark bookmark);
  void updateBookmark(Bookmark bookmark);
  void deleteBookmark(String id);
  void toggleFavorite(String id);
  
  // Import/Export
  String exportToJson();
  void importFromJson(String jsonString);
  
  // Filtering
  List<Bookmark> getBookmarksByFolder(String? folder);
}
```

**Usage:**
```dart
final provider = Provider.of<BookmarksProvider>(context);

// Add bookmark
provider.addBookmark(Bookmark(
  title: 'Google',
  url: 'https://google.com',
  isFavorite: true,
));

// Get favorites
final favorites = provider.favorites;

// Export to JSON
final json = provider.exportToJson();

// Import from JSON
provider.importFromJson(jsonString);
```

### TasksProvider

Manages task operations and storage.

```dart
class TasksProvider extends ChangeNotifier {
  List<Task> get tasks;                   // All tasks
  List<Task> get activeTasks;             // Incomplete tasks
  List<Task> get completedTasks;          // Completed tasks
  List<Task> get overdueTasks;            // Overdue tasks
  List<Task> get todayTasks;              // Due today
  List<Task> get upcomingTasks;           // Due within 7 days
  List<String> get categories;            // List of categories
  
  // CRUD Operations
  void addTask(Task task);
  void updateTask(Task task);
  void deleteTask(String id);
  void toggleTask(String id);
  void deleteCompletedTasks();
  
  // Import/Export
  String exportToJson();
  void importFromJson(String jsonString);
  
  // Filtering
  List<Task> getTasksByCategory(String? category);
}
```

**Usage:**
```dart
final provider = Provider.of<TasksProvider>(context);

// Add task
provider.addTask(Task(
  title: 'Buy groceries',
  category: 'Shopping',
  dueDate: DateTime.now().add(Duration(days: 1)),
));

// Toggle completion
provider.toggleTask(taskId);

// Get overdue tasks
final overdue = provider.overdueTasks;

// Delete all completed
provider.deleteCompletedTasks();
```

## Storage Service

### HiveService

Handles local data persistence using Hive.

```dart
class HiveService {
  // Box names
  static const String bookmarksBox = 'bookmarks_box';
  static const String tasksBox = 'tasks_box';
  static const String settingsBox = 'settings_box';
  
  // Initialize Hive and open boxes
  static Future<void> init();
  
  // Get box instances
  static Box getBookmarksBox();
  static Box getTasksBox();
  static Box getSettingsBox();
  
  // Clear all data
  static Future<void> clearAllData();
  
  // Close Hive
  static Future<void> close();
}
```

**Usage:**
```dart
// Initialize (called in main.dart)
await HiveService.init();

// Get box
final box = HiveService.getBookmarksBox();

// Save data
box.put('key', jsonEncode(data));

// Get data
final data = box.get('key');

// Clear all data
await HiveService.clearAllData();
```

## Utility Classes

### UrlValidator

URL validation and manipulation utilities.

```dart
class UrlValidator {
  // Check if URL is valid
  static bool isValidUrl(String url);
  
  // Add https:// if missing
  static String ensureHttps(String url);
  
  // Extract domain from URL
  static String? getDomain(String url);
  
  // Get favicon URL for domain
  static String getFaviconUrl(String url);
}
```

### DateTimeUtils

Date and time formatting utilities.

```dart
class DateTimeUtils {
  static String formatDate(DateTime date);
  static String formatDateTime(DateTime dateTime);
  static String formatTime(DateTime time);
  static String getRelativeTime(DateTime date);
  static bool isToday(DateTime date);
  static bool isTomorrow(DateTime date);
  static bool isOverdue(DateTime date);
  static String getDateLabel(DateTime date);
}
```

## Widget Components

### SearchBarWidget

Reusable Google search bar component.

```dart
SearchBarWidget({
  Key? key,
  bool autoFocus = false,
  String? placeholder,
})
```

### LoadingWidget

Loading indicator component.

```dart
LoadingWidget({
  Key? key,
  String? message,
  double size = 48,
})
```

### EmptyStateWidget

Empty state placeholder.

```dart
EmptyStateWidget({
  Key? key,
  required IconData icon,
  required String title,
  String? subtitle,
  Widget? action,
})
```

## Dialog Helpers

### ConfirmDialog

Show confirmation dialog.

```dart
Future<bool> ConfirmDialog.show({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDangerous = false,
})
```

### InfoDialog

Show information dialog.

```dart
Future<void> InfoDialog.show({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'OK',
})
```

### InputDialog

Show input dialog.

```dart
Future<String?> InputDialog.show({
  required BuildContext context,
  required String title,
  String? initialValue,
  String? hint,
  String? label,
  int maxLines = 1,
  TextInputType? keyboardType,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
})
```

### LoadingDialog

Show/hide loading dialog.

```dart
// Show loading
LoadingDialog.show(context, message: 'Processing...');

// Hide loading
LoadingDialog.hide(context);
```

## Constants

### AppConstants

Application-wide constants.

```dart
class AppConstants {
  // App Info
  static const String appName = 'Personal Homepage';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration shortAnimation;
  static const Duration mediumAnimation;
  static const Duration longAnimation;
  
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  
  // URLs
  static const String googleSearchUrl;
  
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
```

## Events and Callbacks

### Bookmark Events

```dart
// When bookmark is added
onBookmarkAdded(Bookmark bookmark)

// When bookmark is updated
onBookmarkUpdated(Bookmark bookmark)

// When bookmark is deleted
onBookmarkDeleted(String id)
```

### Task Events

```dart
// When task is added
onTaskAdded(Task task)