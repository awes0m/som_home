import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:som_home/core/logging.dart';
import 'lib/core/utils/html_bookmark_parser.dart';

void main() async {
  final htmlContent = await File('test_bookmarks.html').readAsString();
  Log.i('HTML Content length: ${htmlContent.length}');

  final document = html_parser.parse(htmlContent);
  Log.i('Document body children: ${document.body?.children.length}');

  // Find DL elements
  final dlElements = document.querySelectorAll('dl');
  Log.i('Found ${dlElements.length} DL elements');

  // Check the structure
  final rootDl = document.querySelector('dl');
  if (rootDl != null) {
    Log.i('Root DL has ${rootDl.children.length} children');
    for (final child in rootDl.children) {
      Log.i('  Child: ${child.localName}');
    }
  }

  final bookmarks = HtmlBookmarkParser.parseHtmlBookmarks(htmlContent);

  Log.i('Parsed ${bookmarks.length} bookmarks:');
  for (final bookmark in bookmarks) {
    Log.i('- ${bookmark.title}: ${bookmark.url} (folder: ${bookmark.folder})');
  }
}