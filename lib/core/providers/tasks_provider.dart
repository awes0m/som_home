import 'dart:convert';
import 'package:flutter/material.dart';
import '../storage/hive_service.dart';
import '../models/models.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _tasks = [];

  TasksProvider() {
    loadTasks();
  }

  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> loadTasks() async {
    if (HiveService.isAuthenticated) {
      // Try to load from cloud first, fallback to local if empty
      _tasks = await HiveService.loadTasksFromCloud();
      if (_tasks.isEmpty) {
        // Load from local storage
        final box = HiveService.getTasksBox();
        _tasks = [];
        for (var key in box.keys) {
          try {
            final raw = box.get(key);
            if (raw is String) {
              final Map<String, dynamic> json = jsonDecode(raw);
              _tasks.add(Task.fromJson(json));
            }
          } catch (_) {
            // Skip invalid entries
          }
        }
        // Sync local data to cloud
        if (_tasks.isNotEmpty) {
          await HiveService.syncTasksToCloud(_tasks);
        }
      }
    } else {
      // Load from Hive
      final box = HiveService.getTasksBox();
      _tasks = [];
      for (var key in box.keys) {
        try {
          final raw = box.get(key);
          if (raw is String) {
            final Map<String, dynamic> json = jsonDecode(raw);
            _tasks.add(Task.fromJson(json));
          }
        } catch (_) {
          // Skip invalid entries
        }
      }
    }
    _tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    // Save to local storage
    final box = HiveService.getTasksBox();
    box.clear();
    for (var task in tasks) {
      box.put(task.id, jsonEncode(task.toJson()));
    }
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    _saveTask(task);
    await HiveService.syncTasksToCloud(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _saveTask(task);
      await HiveService.syncTasksToCloud(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    _saveTask(task);
    await HiveService.syncTasksToCloud(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    HiveService.getTasksBox().delete(id);
    await HiveService.syncTasksToCloud(_tasks);
    notifyListeners();
  }

  void _saveTask(Task task) {
    HiveService.getTasksBox().put(task.id, jsonEncode(task.toJson()));
  }

  Future<void> deleteCompletedTasks() async {
    final completed = completedTasks.map((t) => t.id).toList();
    for (final id in completed) {
      await deleteTask(id);
    }
  }

  String exportToJson() {
    final data = _tasks.map((t) => t.toJson()).toList();
    return jsonEncode(data);
  }

  Future<void> importFromJson(String jsonString) async {
    try {
      final List<dynamic> data = jsonDecode(jsonString);
      for (var item in data) {
        final task = Task.fromJson(item);
        await addTask(task);
      }
    } catch (_) {
      // Ignore parse errors
    }
  }

  List<Task> getTasksByCategory(String? category) {
    if (category == null || category.isEmpty) return _tasks;
    return _tasks.where((t) => t.category == category).toList();
  }
}
