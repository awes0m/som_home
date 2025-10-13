import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Box names
  static const String bookmarksBox = 'bookmarks_box';
  static const String tasksBox = 'tasks_box';
  static const String settingsBox = 'settings_box';

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(bookmarksBox),
      Hive.openBox<String>(tasksBox),
      Hive.openBox(settingsBox),
    ]);
  }

  // Get box instances
  static Box<String> getBookmarksBox() => Hive.box<String>(bookmarksBox);
  static Box<String> getTasksBox() => Hive.box<String>(tasksBox);
  static Box getSettingsBox() => Hive.box(settingsBox);

  // Clear all data
  static Future<void> clearAllData() async {
    await getBookmarksBox().clear();
    await getTasksBox().clear();
    await getSettingsBox().clear();
  }

  // Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
