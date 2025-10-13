import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../widgets/dialog_widget.dart';
import 'backup_file_saver.dart';

class BackupService {
  final Box bookmarksBox;
  final Box tasksBox;
  final Box settingsBox;

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
    await settingsBox.clear();

    // Restore bookmarks
    for (var item in data['bookmarks']) {
      // Assuming Bookmark model can be created from a map
      // You might need to adjust this based on your actual Bookmark model
      // For now, directly add the map as a dynamic object
      await bookmarksBox.add(item);
    }

    // Restore tasks
    for (var item in data['tasks']) {
      // Assuming Task model can be created from a map
      // For now, directly add the map as a dynamic object
      await tasksBox.add(item);
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
      }

      final String message = kIsWeb
          ? 'Your configuration download should begin automatically.'
          : 'Your configuration has been saved to $savedLocation.';

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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        // User canceled the picker
        return;
      }

      String jsonString;
      
      if (kIsWeb) {
        // On web, use bytes since file paths are not available
        if (result.files.single.bytes == null) {
          debugPrint('No file bytes available');
          return;
        }
        final bytes = result.files.single.bytes!;
        jsonString = utf8.decode(bytes);
      } else {
        // On desktop/mobile, use file path
        if (result.files.single.path == null) {
          debugPrint('No file path available');
          return;
        }
        final File file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }
      
      await importConfiguration(jsonString);
    } catch (e, stackTrace) {
      debugPrint('Error importing configuration: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
