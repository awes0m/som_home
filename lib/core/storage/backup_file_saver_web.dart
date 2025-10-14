import 'dart:convert';
import 'dart:html' as html;

Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  try {
    final bytes = utf8.encode(jsonContent);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrl(blob);
    
    // Create anchor element with proper attributes for download
    final anchor = html.AnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    
    // Add to document, click, then remove
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up the object URL after a short delay to ensure download starts
    Future.delayed(const Duration(milliseconds: 100), () {
      html.Url.revokeObjectUrl(url);
    });
    
    return fileName;
  } catch (e) {
    print('Error saving file: $e');
    return null;
  }
}
