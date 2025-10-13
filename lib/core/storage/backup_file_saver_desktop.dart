import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  final directory = await FilePicker.platform.getDirectoryPath();
  if (directory == null) {
    return null;
  }

  final file = File('$directory/$fileName');
  await file.writeAsString(jsonContent);
  return file.path;
}
