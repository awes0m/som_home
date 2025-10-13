import 'dart:convert';
import 'package:uuid/uuid.dart';

class Bookmark {
  final String id; // Unique identifier (UUID)
  String title; // Display title
  String url; // Website URL
  String? folder; // Optional folder name
  bool isFavorite; // Favorite flag
  DateTime createdAt; // Creation timestamp

  Bookmark({
    String? id,
    required this.title,
    required this.url,
    this.folder,
    this.isFavorite = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'folder': folder,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as String?,
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        folder: json['folder'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  String toString() => jsonEncode(toJson());
}
