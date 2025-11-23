import 'dart:io';
import 'package:som_home/core/logging.dart';

import 'lib/core/utils/html_bookmark_parser.dart';
import 'lib/core/models/models.dart';

void main() async {
  Log.i('Testing improved HTML bookmark parser...\n');

  // Read the bookmark file
  final file = File('favourites_15_09_2025.html');
  if (!await file.exists()) {
    Log.e('Error: bookmark file not found!');
    return;
  }

  final content = await file.readAsString();
  Log.i('Loaded bookmark file: ${file.path}');
  Log.i('File size: ${content.length} characters\n');

  // Parse the bookmarks
  final stopwatch = Stopwatch()..start();
  final bookmarks = HtmlBookmarkParser.parseHtmlBookmarks(content);
  stopwatch.stop();

  Log.i('Parse Results:');
  Log.i('- Parsed in: ${stopwatch.elapsedMilliseconds}ms');
  Log.i('- Total bookmarks found: ${bookmarks.length}');

  // Group by folder for analysis
  final Map<String?, List<Bookmark>> folderGroups = {};
  for (final bookmark in bookmarks) {
    final folder = bookmark.folder ?? '(Root)';
    folderGroups.putIfAbsent(folder, () => []).add(bookmark);
  }

  Log.i('\nFolder breakdown:');
  Log.i('- Root level: ${folderGroups.remove(null)?.length ?? 0} bookmarks');
  Log.i('- Folders found: ${folderGroups.length}');

  int maxDepth = 0;
  for (final folder in folderGroups.keys) {
    if (folder == null) continue;
    final depth = folder.split(' > ').length;
    maxDepth = maxDepth < depth ? depth : maxDepth;
    
    final count = folderGroups[folder]?.length ?? 0;
    final truncatedFolder = folder.length > 50 
        ? '${folder.substring(0, 47)}...'
        : folder;
    Log.i('  • $truncatedFolder: $count bookmarks');
  }

  Log.i('\nDetailed results:');
  Log.i('- Maximum folder depth: $maxDepth levels');
  Log.i('- Sample bookmarks:');

  // Show first few bookmarks as examples
  for (int i = 0; i < bookmarks.length && i < 5; i++) {
    final b = bookmarks[i];
    final folder = b.folder ?? '(Root)';
    final truncatedTitle = b.title.length > 40 
        ? '${b.title.substring(0, 37)}...'
        : b.title;
    final truncatedUrl = b.url.length > 50 
        ? '${b.url.substring(0, 47)}...'
        : b.url;
    Log.i('  $i. Title: $truncatedTitle');
    Log.i('     URL: $truncatedUrl');
    Log.i('     Folder: $folder');
    Log.i('');
  }

  if (bookmarks.length > 5) {
    Log.i('  ... and ${bookmarks.length - 5} more bookmarks');
  }

  Log.i('\nParser test completed successfully! ✅');
}
