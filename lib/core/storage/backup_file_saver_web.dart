import 'dart:convert';
import 'package:web/web.dart' as web;
import 'dart:js_interop'; // Required for JS type conversions

/// Saves a JSON string as a file and prompts the user to download it.
///
/// This function is intended for web platforms.
/// [fileName] is the name of the file to be saved (e.g., "backup.json").
/// [jsonContent] is the JSON data as a string.
/// Returns the [fileName] on successful download initiation, or `null` on error.
Future<String?> saveJsonFile(String fileName, String jsonContent) async {
  try {
    // Encode the JSON string into a list of bytes (UTF-8)
    final bytes = utf8.encode(jsonContent);

    // Create a Blob from the bytes with the correct MIME type for JSON
    final blob = web.Blob(
      [bytes.toJS].toJS, // Convert Dart list to a JS Array
      web.BlobPropertyBag(type: 'application/json'),
    );

    // Create an object URL for the Blob
    final url = web.URL.createObjectURL(blob);

    // Create an anchor element ('<a>') to trigger the download
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    // Append the anchor to the document, click it, and then remove it
    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);

    // Revoke the object URL after a short delay to free up resources
    Future.delayed(const Duration(milliseconds: 100), () {
      web.URL.revokeObjectURL(url);
    });

    return fileName;
  } catch (e) {
    // ignore: avoid_print
    print('Error saving file: $e');
    return null;
  }
}
