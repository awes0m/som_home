import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';

import '../../widgets/dialog_widget.dart';
import 'backup_file_saver.dart';

class BackupService {
  final Box<String> bookmarksBox;
  final Box<String> tasksBox;
  final Box<dynamic> settingsBox;

  BackupService({
    required this.bookmarksBox,
    required this.tasksBox,
    required this.settingsBox,
  });

  Future<String> exportConfiguration() async {
    final Map<String, dynamic> data = {
      'bookmarks': bookmarksBox.values.toList(),
      'tasks': tasksBox.values.toList(),
      'settings': settingsBox.toMap(),
    };
    return jsonEncode(data);
  }

  Future<void> importConfiguration(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // Validate structure
    if (!data.containsKey('bookmarks') ||
        !data.containsKey('tasks') ||
        !data.containsKey('settings')) {
      throw const FormatException('Invalid backup file structure.');
    }

    // Clear existing data
    await bookmarksBox.clear();
    await tasksBox.clear();
    await settingsBox.clear();    // Restore bookmarks
    for (var item in data['bookmarks']) {
      // Convert the item back to JSON string as that's how it's stored in the box
      if (item is String) {
        // If it's already a string, add it directly
        await bookmarksBox.add(item);
      } else {
        // If it's a map/object, encode it to JSON string
        await bookmarksBox.add(jsonEncode(item));
      }
    }

    // Restore tasks
    for (var item in data['tasks']) {
      // Convert the item back to JSON string as that's how it's stored in the box
      if (item is String) {
        // If it's already a string, add it directly
        await tasksBox.add(item);
      } else {
        // If it's a map/object, encode it to JSON string
        await tasksBox.add(jsonEncode(item));
      }
    }

    // Restore settings
    data['settings'].forEach((key, value) {
      settingsBox.put(key, value);
    });
  }

  Future<void> pickAndExportFile(context) async {
    try {
      final String jsonContent = await exportConfiguration();
      final String fileName =
          'som_home_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';

      final String? savedLocation = await saveJsonFile(fileName, jsonContent);

      if (savedLocation == null) {
        // User likely cancelled the operation.
        return;
      }      final String message = 'Your configuration download should begin automatically.';

      ConfirmDialog.show(
        context: context,
        title: 'Configuration exported',
        message: message,
      );
      debugPrint('Configuration exported: $savedLocation');
    } catch (e, stackTrace) {
      debugPrint('Error exporting configuration: $e');
      debugPrintStack(stackTrace: stackTrace);    }
  }

  Future<void> pickAndImportFile() async {
    try {
      // Use file_picker for better cross-platform support
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        // For web, use bytes
        final bytes = result.files.single.bytes!;
        final jsonString = utf8.decode(bytes);
        await importConfiguration(jsonString);
        debugPrint('Configuration imported successfully');
      } else if (result != null && result.files.single.path != null) {
        // For other platforms, use path (fallback, though this is primarily for web)
        final file = result.files.single;
        if (file.path != null) {
          // This would be for non-web platforms
          debugPrint('File path import not implemented for non-web platforms');
        }
      } else {
        debugPrint('No file selected for import');
      }
    } catch (e, stackTrace) {
      debugPrint('Error importing configuration: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow; // Re-throw to allow UI to handle the error
    }
  }
}
