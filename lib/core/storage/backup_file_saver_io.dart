import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) {
      return null;
    }
    final file = File('$directory/$fileName');
    await file.writeAsString(jsonContent);
    return file.path;
  }

  // Fallback for mobile targets
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(jsonContent);
  return file.path;
}
