import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import '../models/bookmark.dart';
import '../models/task.dart';

class HiveService {
  // Box names
  static const String bookmarksBox = 'bookmarks_box';
  static const String tasksBox = 'tasks_box';
  static const String settingsBox = 'settings_box';
  static const String backupBox = 'backup_box';
  static bool _initialized = false;

  // Services
  static final AuthService _authService = AuthService();
  static final FirestoreService _firestoreService = FirestoreService();

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

  // Cloud sync methods
  static Future<void> syncBookmarksToCloud(List<Bookmark> bookmarks) async {
    if (_authService.currentUser != null) {
      await _firestoreService.syncBookmarks(bookmarks);
    }
  }

  static Future<void> syncTasksToCloud(List<Task> tasks) async {
    if (_authService.currentUser != null) {
      await _firestoreService.syncTasks(tasks);
    }
  }

  static Future<void> syncSettingsToCloud(Map<String, dynamic> settings) async {
    if (_authService.currentUser != null) {
      await _firestoreService.syncSettings(settings);
    }
  }

  static Future<List<Bookmark>> loadBookmarksFromCloud() async {
    if (_authService.currentUser != null) {
      return await _firestoreService.loadBookmarks();
    }
    return [];
  }

  static Future<List<Task>> loadTasksFromCloud() async {
    if (_authService.currentUser != null) {
      return await _firestoreService.loadTasks();
    }
    return [];
  }

  static Future<Map<String, dynamic>> loadSettingsFromCloud() async {
    if (_authService.currentUser != null) {
      return await _firestoreService.loadSettings();
    }
    return {};
  }

  // Merge local and cloud data on sign-in
  // Strategy:
  // - Load lists from cloud and local
  // - Build a union by id, preferring cloud items when ids collide
  // - Persist merged set locally and sync back to cloud
  static Future<void> mergeLocalAndCloudOnSignIn() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final cloudBookmarks = await loadBookmarksFromCloud();
      final cloudTasks = await loadTasksFromCloud();

      // Load local bookmarks (stored as JSON strings)
      final localBookmarks = <Bookmark>[];
      final bbox = getBookmarksBox();
      for (var key in bbox.keys) {
        try {
          final raw = bbox.get(key);
          if (raw is String && raw.isNotEmpty) {
            final Map<String, dynamic> json =
                jsonDecode(raw) as Map<String, dynamic>;
            localBookmarks.add(Bookmark.fromJson(json));
          }
        } catch (_) {
          // ignore malformed entries
        }
      }

      // Local tasks
      final localTasks = <Task>[];
      final tbox = getTasksBox();
      for (var key in tbox.keys) {
        try {
          final raw = tbox.get(key);
          if (raw is String && raw.isNotEmpty) {
            final Map<String, dynamic> json =
                jsonDecode(raw) as Map<String, dynamic>;
            localTasks.add(Task.fromJson(json));
          }
        } catch (_) {
          // ignore malformed entries
        }
      }

      // Build merged maps (id -> object), prefer cloud on conflicts
      final Map<String, Bookmark> mergedBookmarks = {};
      for (var bm in localBookmarks) {
        mergedBookmarks[bm.id] = bm;
      }
      for (var bm in cloudBookmarks) {
        mergedBookmarks[bm.id] = bm;
      }

      final Map<String, Task> mergedTasks = {};
      for (var t in localTasks) {
        mergedTasks[t.id] = t;
      }
      for (var t in cloudTasks) {
        mergedTasks[t.id] = t;
      }

      final mergedBookmarkList = mergedBookmarks.values.toList();
      final mergedTaskList = mergedTasks.values.toList();

      // Persist merged locally
      await bbox.clear();
      for (var bm in mergedBookmarkList) {
        bbox.put(bm.id, jsonEncode(bm.toJson()));
      }

      await tbox.clear();
      for (var t in mergedTaskList) {
        tbox.put(t.id, jsonEncode(t.toJson()));
      }

      // Sync merged back to cloud (best-effort)
      await syncBookmarksToCloud(mergedBookmarkList);
      await syncTasksToCloud(mergedTaskList);
    } catch (e) {
      // Silently fail; merge is best-effort
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _authService.currentUser != null;

  // Get current user
  static User? get currentUser => _authService.currentUser;
}
