import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'lib/core/utils/html_bookmark_parser.dart';

void main() async {
  final htmlContent = await File('test_bookmarks.html').readAsString();
  print('HTML Content length: ${htmlContent.length}');

  final document = html_parser.parse(htmlContent);
  print('Document body children: ${document.body?.children.length}');

  // Find DL elements
  final dlElements = document.querySelectorAll('dl');
  print('Found ${dlElements.length} DL elements');

  // Check the structure
  final rootDl = document.querySelector('dl');
  if (rootDl != null) {
    print('Root DL has ${rootDl.children.length} children');
    for (final child in rootDl.children) {
      print('  Child: ${child.localName}');
    }
  }

  final bookmarks = HtmlBookmarkParser.parseHtmlBookmarks(htmlContent);

  print('Parsed ${bookmarks.length} bookmarks:');
  for (final bookmark in bookmarks) {
    print('- ${bookmark.title}: ${bookmark.url} (folder: ${bookmark.folder})');
  }
}