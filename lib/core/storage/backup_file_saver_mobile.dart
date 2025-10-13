import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(jsonContent);
  return file.path;
}
