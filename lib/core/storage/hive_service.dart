import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Box names
  static const String bookmarksBox = 'bookmarks_box';
  static const String tasksBox = 'tasks_box';
  static const String settingsBox = 'settings_box';
  static const String backupBox = 'backup_box';
  static bool _initialized = false;

  // Initialize Hive and open boxes
  static Future<void> init() async {
    if (_initialized) return; // prevent double-initialization on hot reload
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(backupBox),
      Hive.openBox<String>(bookmarksBox),
      Hive.openBox<String>(tasksBox),
      Hive.openBox<dynamic>(settingsBox),
    ]);
    _initialized = true;
  }

  // Get box instances
  static Box<String> getBookmarksBox() => Hive.box<String>(bookmarksBox);
  static Box<String> getTasksBox() => Hive.box<String>(tasksBox);
  static Box getSettingsBox() => Hive.box(settingsBox);
  static Box getBackupBox() => Hive.box(backupBox);

  // Clear all data
  static Future<void> clearAllData() async {
    await getBookmarksBox().clear();
    await getTasksBox().clear();
    await getSettingsBox().clear();
    await getBackupBox().clear();
  }

  // Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
