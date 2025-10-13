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

  void loadTasks() {
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
    _tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTask(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _saveTask(task);
      notifyListeners();
    }
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    _saveTask(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    HiveService.getTasksBox().delete(id);
    notifyListeners();
  }

  void _saveTask(Task task) {
    HiveService.getTasksBox().put(task.id, jsonEncode(task.toJson()));
  }

  void deleteCompletedTasks() {
    final completed = completedTasks.map((t) => t.id).toList();
    for (final id in completed) {
      deleteTask(id);
    }
  }

  String exportToJson() {
    final data = _tasks.map((t) => t.toJson()).toList();
    return jsonEncode(data);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> data = jsonDecode(jsonString);
      for (var item in data) {
        final task = Task.fromJson(item);
        addTask(task);
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
