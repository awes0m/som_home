import 'dart:convert';
import 'package:uuid/uuid.dart';

class Task {
  final String id; // Unique identifier (UUID)
  String title; // Task title
  String? notes; // Optional notes
  String? category; // Optional category
  DateTime? dueDate; // Optional due date
  bool isCompleted; // Completion status
  DateTime createdAt; // Creation timestamp

  Task({
    String? id,
    required this.title,
    this.notes,
    this.category,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String?,
        title: json['title'] as String? ?? '',
        notes: json['notes'] as String?,
        category: json['category'] as String?,
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String)
            : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  String toString() => jsonEncode(toJson());
}
