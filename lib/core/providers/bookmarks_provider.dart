import 'dart:convert';
import 'package:flutter/material.dart';
import '../storage/hive_service.dart';
import '../models/models.dart';
import '../utils/html_bookmark_parser.dart';

class BookmarksProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];

  BookmarksProvider() {
    loadBookmarks();
  }

  List<Bookmark> get bookmarks => _bookmarks;
  List<Bookmark> get favorites =>
      _bookmarks.where((b) => b.isFavorite).toList();

  List<String> get folders {
    final folderSet = <String>{};
    for (var b in _bookmarks) {
      if (b.folder != null && b.folder!.isNotEmpty) {
        folderSet.add(b.folder!);
      }
    }
    return folderSet.toList()..sort();
  }

  Future<void> loadBookmarks() async {
    if (HiveService.isAuthenticated) {
      // Try to load from cloud first, fallback to local if empty
      _bookmarks = await HiveService.loadBookmarksFromCloud();
      if (_bookmarks.isEmpty) {
        // Load from local storage
        final box = HiveService.getBookmarksBox();
        _bookmarks = [];
        for (var key in box.keys) {
          try {
            final raw = box.get(key);
            if (raw is String) {
              final Map<String, dynamic> json = jsonDecode(raw);
              _bookmarks.add(Bookmark.fromJson(json));
            }
          } catch (_) {
            // Skip invalid entries
          }
        }
        // Sync local data to cloud
        if (_bookmarks.isNotEmpty) {
          await HiveService.syncBookmarksToCloud(_bookmarks);
        }
      }
    } else {
      // Load from Hive
      final box = HiveService.getBookmarksBox();
      _bookmarks = [];
      for (var key in box.keys) {
        try {
          final raw = box.get(key);
          if (raw is String) {
            final Map<String, dynamic> json = jsonDecode(raw);
            _bookmarks.add(Bookmark.fromJson(json));
          }
        } catch (_) {
          // Skip invalid entries
        }
      }
    }
    _bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  void setBookmarks(List<Bookmark> bookmarks) {
    _bookmarks = bookmarks;
    // Save to local storage
    final box = HiveService.getBookmarksBox();
    box.clear();
    for (var bookmark in bookmarks) {
      box.put(bookmark.id, jsonEncode(bookmark.toJson()));
    }
    notifyListeners();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    _bookmarks.insert(0, bookmark);
    _saveBookmark(bookmark);
    await HiveService.syncBookmarksToCloud(_bookmarks);
    notifyListeners();
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      _bookmarks[index] = bookmark;
      _saveBookmark(bookmark);
      await HiveService.syncBookmarksToCloud(_bookmarks);
      notifyListeners();
    }
  }

  Future<void> deleteBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    HiveService.getBookmarksBox().delete(id);
    await HiveService.syncBookmarksToCloud(_bookmarks);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _bookmarks.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookmarks[idx].isFavorite = !_bookmarks[idx].isFavorite;
      _saveBookmark(_bookmarks[idx]);
      await HiveService.syncBookmarksToCloud(_bookmarks);
      notifyListeners();
    }
  }

  void _saveBookmark(Bookmark bookmark) {
    HiveService.getBookmarksBox().put(
      bookmark.id,
      jsonEncode(bookmark.toJson()),
    );
  }

  String exportToJson() {
    final data = _bookmarks.map((b) => b.toJson()).toList();
    return jsonEncode(data);
  }

  Future<void> importFromJson(String jsonString) async {
    try {
      final List<dynamic> data = jsonDecode(jsonString);
      for (var item in data) {
        final bookmark = Bookmark.fromJson(item);
        await addBookmark(bookmark);
      }
    } catch (_) {
      // Ignore parse errors
    }
  }

  Future<void> importFromHtml(String htmlString) async {
    try {
      final bookmarks = HtmlBookmarkParser.parseHtmlBookmarks(htmlString);
      for (var bookmark in bookmarks) {
        // Check if bookmark already exists to avoid duplicates
        final exists = _bookmarks.any(
          (b) => b.url == bookmark.url && b.title == bookmark.title,
        );
        if (!exists) {
          await addBookmark(bookmark);
        }
      }
    } catch (e) {
      // Ignore parse errors
      // Error importing HTML bookmarks: $e
    }
  }

  List<Bookmark> getBookmarksByFolder(String? folder) {
    if (folder == null || folder.isEmpty) return _bookmarks;
    return _bookmarks.where((b) => b.folder == folder).toList();
  }
}
