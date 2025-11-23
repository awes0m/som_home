import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/models.dart';

class HtmlBookmarkParser {
  /// Parse HTML bookmarks file (Netscape bookmark format)
  static List<Bookmark> parseHtmlBookmarks(String htmlContent) {
    final List<Bookmark> bookmarks = [];

    try {
      final document = html_parser.parse(htmlContent);
      
      // Find the main DL container (description list)
      final mainDl = document.querySelector('dl');
      if (mainDl != null) {
        _parseDescriptionList(mainDl, bookmarks, null);
      }
    } catch (e) {
      // Error parsing HTML bookmarks: $e
      // Return what we've parsed so far
    }

    return bookmarks;
  }

  /// Parse a description list (DL) element recursively
  static void _parseDescriptionList(
    Element dlElement,
    List<Bookmark> bookmarks,
    String? currentFolderPath,
  ) {
    Element? currentElement = _getFirstChild(dlElement);
    
    while (currentElement != null) {
      if (currentElement.localName == 'dt') {
        // Check if this DT contains a folder (H3) or a bookmark (A)
        final h3 = currentElement.querySelector('h3');
        final anchor = currentElement.querySelector('a');

        if (h3 != null) {
          // This is a folder
          final folderName = _cleanText(h3.text);
          if (folderName.isNotEmpty) {
            final fullFolderPath = _buildFolderPath(
              currentFolderPath,
              folderName,
            );
            
            // Look for the next sibling DL that contains this folder's bookmarks
            Element? nextElement = _getNextSibling(currentElement);
            while (nextElement != null && nextElement.localName != 'dl') {
              nextElement = _getNextSibling(nextElement);
            }
            
            if (nextElement?.localName == 'dl') {
              // Recursively parse the folder's contents
              final dlElement = nextElement!;
              _parseDescriptionList(dlElement, bookmarks, fullFolderPath);
            }
          }
        } else if (anchor != null) {
          // This is a bookmark
          final bookmark = _parseBookmarkAnchor(anchor, currentFolderPath);
          if (bookmark != null) {
            bookmarks.add(bookmark);
          }
        }
      }
      
      currentElement = _getNextSibling(currentElement);
    }
  }

  /// Parse a bookmark anchor tag
  static Bookmark? _parseBookmarkAnchor(Element anchor, String? folderPath) {
    final url = anchor.attributes['href'];
    final title = _cleanText(anchor.text);
    
    // Validate URL and title
    if (url == null || url.isEmpty || title.isEmpty) {
      return null;
    }
    
    // Skip javascript: and other non-http(s) URLs except file://
    if (!_isValidUrl(url)) {
      return null;
    }
    
    // Extract favicon data (optional, currently not storing)
    // final iconData = anchor.attributes['icon'];
    // final addDate = anchor.attributes['add_date'];
    
    return Bookmark(
      title: title,
      url: url,
      folder: folderPath,
    );
  }

  /// Build folder path, limiting depth to prevent overly long paths
  static String _buildFolderPath(String? parentPath, String folderName) {
    if (parentPath == null || parentPath.isEmpty) {
      return folderName;
    }
    
    // Limit folder depth to 3 levels to keep paths manageable
    final pathParts = parentPath.split(' > ');
    if (pathParts.length >= 3) {
      // Use only the last 2 parts plus the new folder
      return '${pathParts[pathParts.length - 2]} > ${pathParts[pathParts.length - 1]} > $folderName';
    }
    
    return '$parentPath > $folderName';
  }

  /// Check if URL is valid for import
  static bool _isValidUrl(String url) {
    // Allow http, https, and file URLs
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('file://')) {
      return true;
    }
    
    // Reject javascript:, data:, about:, chrome:, etc.
    return false;
  }

  /// Clean text by trimming and removing extra whitespace
  static String _cleanText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\n\r\t]'), '');
  }

  /// Get first child element (skip text nodes)
  static Element? _getFirstChild(Element parent) {
    for (final node in parent.nodes) {
      if (node is Element) {
        return node;
      }
    }
    return null;
  }

  /// Get next sibling element (skip text nodes)
  static Element? _getNextSibling(Element element) {
    final parent = element.parent;
    if (parent == null) return null;

    bool foundCurrent = false;
    for (final node in parent.nodes) {
      if (foundCurrent && node is Element) {
        return node;
      }
      if (node == element) {
        foundCurrent = true;
      }
    }

    return null;
  }

  /// Export bookmarks to HTML format
  static String exportToHtml(List<Bookmark> bookmarks) {
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE NETSCAPE-Bookmark-file-1>');
    buffer.writeln('<!-- This is an automatically generated file.');
    buffer.writeln('     It will be read and overwritten.');
    buffer.writeln('     DO NOT EDIT! -->');
    buffer.writeln('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">');
    buffer.writeln('<TITLE>Bookmarks</TITLE>');
    buffer.writeln('<H1>Bookmarks</H1>');
    buffer.writeln('<DL><p>');
    
    // Group bookmarks by folder
    final Map<String?, List<Bookmark>> folderGroups = {};
    for (final bookmark in bookmarks) {
      final folder = bookmark.folder ?? '';
      folderGroups.putIfAbsent(folder, () => []).add(bookmark);
    }
    
    // Write root bookmarks first
    if (folderGroups.containsKey('') || folderGroups.containsKey(null)) {
      final rootBookmarks = [
        ...?folderGroups[''],
        ...?folderGroups[null],
      ];
      for (final bookmark in rootBookmarks) {
        _writeBookmarkHtml(buffer, bookmark, 1);
      }
    }
    
    // Write folders
    final folders = folderGroups.keys
        .where((k) => k != null && k.isNotEmpty)
        .toList()
      ..sort();
    
    for (final folder in folders) {
      if (folder == null || folder.isEmpty) continue;
      
      _writeFolderHtml(buffer, folder, folderGroups[folder]!, 1);
    }
    
    buffer.writeln('</DL><p>');
    
    return buffer.toString();
  }

  static void _writeFolderHtml(
    StringBuffer buffer,
    String folderName,
    List<Bookmark> bookmarks,
    int indent,
  ) {
    final indentStr = '    ' * indent;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    buffer.writeln('$indentStr<DT><H3 ADD_DATE="$timestamp">$folderName</H3>');
    buffer.writeln('$indentStr<DL><p>');
    
    for (final bookmark in bookmarks) {
      _writeBookmarkHtml(buffer, bookmark, indent + 1);
    }
    
    buffer.writeln('$indentStr</DL><p>');
  }

  static void _writeBookmarkHtml(
    StringBuffer buffer,
    Bookmark bookmark,
    int indent,
  ) {
    final indentStr = '    ' * indent;
    final timestamp = bookmark.createdAt.millisecondsSinceEpoch ~/ 1000;
    final title = _escapeHtml(bookmark.title);
    final url = _escapeHtml(bookmark.url);
    
    buffer.writeln(
      '$indentStr<DT><A HREF="$url" ADD_DATE="$timestamp">$title</A>',
    );
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
