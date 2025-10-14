import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/models.dart';

class HtmlBookmarkParser {
  static List<Bookmark> parseHtmlBookmarks(String htmlContent) {
    final List<Bookmark> bookmarks = [];
    
    try {
      final document = html_parser.parse(htmlContent);
      
      // Find all bookmark links and folders
      _parseBookmarkNode(document.body, bookmarks, null);
      
    } catch (e) {
      // If parsing fails, return empty list
      // Error parsing HTML bookmarks: $e
    }
    
    return bookmarks;
  }
  
  static void _parseBookmarkNode(Element? node, List<Bookmark> bookmarks, String? currentFolder) {
    if (node == null) return;
    
    for (final child in node.children) {
      if (child.localName == 'dt') {
        // Check if this is a folder (H3 tag) or bookmark (A tag)
        final h3 = child.querySelector('h3');
        final anchor = child.querySelector('a');
        
        if (h3 != null) {
          // This is a folder
          final folderName = h3.text.trim();
          final nextSibling = _getNextSibling(child);
          
          if (nextSibling?.localName == 'dl') {
            // Parse bookmarks within this folder
            _parseBookmarkNode(nextSibling, bookmarks, folderName);
          }
        } else if (anchor != null) {
          // This is a bookmark
          final url = anchor.attributes['href'];
          final title = anchor.text.trim();
          
          if (url != null && url.isNotEmpty && title.isNotEmpty) {
            final bookmark = Bookmark(
              title: title,
              url: url,
              folder: currentFolder,
            );
            bookmarks.add(bookmark);
          }
        }
      } else if (child.localName == 'dl') {
        // Continue parsing within description list
        _parseBookmarkNode(child, bookmarks, currentFolder);
      } else {
        // Recursively check other elements
        _parseBookmarkNode(child, bookmarks, currentFolder);
      }
    }
  }
  
  static Element? _getNextSibling(Element element) {
    final parent = element.parent;
    if (parent == null) return null;
    
    final children = parent.children;
    final index = children.indexOf(element);
    
    if (index >= 0 && index + 1 < children.length) {
      return children[index + 1];
    }
    
    return null;
  }
}