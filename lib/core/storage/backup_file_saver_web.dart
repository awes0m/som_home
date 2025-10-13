import 'dart:convert';
import 'dart:html' as html;

Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  final bytes = utf8.encode(jsonContent);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrl(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return fileName;
}
