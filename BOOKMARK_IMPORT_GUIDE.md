# Bookmark Import Guide

## Overview
The Som Home app already includes **complete HTML bookmark import functionality**. You can import bookmarks from any browser's exported HTML bookmark file.

## How to Import Bookmarks

### Step 1: Export Bookmarks from Your Browser

#### Chrome/Edge:
1. Open Chrome/Edge
2. Press `Ctrl+Shift+O` (or go to Bookmarks → Bookmark Manager)
3. Click the three dots menu (⋮) in the top right
4. Select "Export bookmarks"
5. Save the HTML file to your computer

#### Firefox:
1. Open Firefox
2. Press `Ctrl+Shift+O` (or go to Bookmarks → Manage Bookmarks)
3. Click "Import and Backup" → "Export Bookmarks to HTML"
4. Save the HTML file to your computer

#### Safari:
1. Open Safari
2. Go to File → Export Bookmarks
3. Save the HTML file to your computer

### Step 2: Import into Som Home App

1. **Open the Som Home app** in your browser
2. **Navigate to the Bookmarks section** (bookmark icon in navigation)
3. **Click the Import button** (📤 file upload icon) in the top toolbar
4. **Select your HTML file** from the file picker dialog
5. **Wait for confirmation** - you'll see a success message: "HTML bookmarks imported successfully"

## Supported Features

### ✅ What Works
- **Standard HTML bookmark format** (exported from any major browser)
- **Folder organization** - maintains your bookmark folder structure
- **Duplicate prevention** - won't import the same bookmark twice
- **Batch import** - imports all bookmarks at once
- **Error handling** - gracefully handles malformed HTML files

### 📁 Folder Support
The import preserves your folder structure:
- Bookmarks Toolbar → "Bookmarks Toolbar" folder
- Custom folders → maintain their names
- Nested folders → flattened to single level (limitation)

### 🔄 File Format Support
- **HTML files** (.html) - Standard browser export format
- **JSON files** (.json) - Som Home's native export format

## Technical Implementation

The bookmark import functionality is implemented across several files:

### Core Components:
1. **`HtmlBookmarkParser`** (`lib/core/utils/html_bookmark_parser.dart`)
   - Parses HTML bookmark files using the `html` package
   - Handles standard Netscape bookmark format
   - Extracts folders (H3 tags) and bookmarks (A tags)

2. **`BookmarksProvider`** (`lib/core/providers/bookmarks_provider.dart`)
   - `importFromHtml(String htmlString)` method
   - Duplicate detection and prevention
   - Integration with local storage

3. **`BookmarksPage`** (`lib/pages/bookmarks_page.dart`)
   - File picker integration using `file_picker` package
   - User interface for import functionality
   - Success/error message handling

### HTML Format Supported:
```html
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<DL>
    <DT><H3>Folder Name</H3>
    <DL>
        <DT><A HREF="https://example.com/">Bookmark Title</A>
    </DL>
    <DT><A HREF="https://example.com/">Root Level Bookmark</A>
</DL>
```

## Testing the Feature

A test bookmark file (`test_bookmarks.html`) has been created in the project root with sample bookmarks organized in folders:
- Bookmarks Toolbar (Google, GitHub, Stack Overflow)
- Development (Flutter, Dart, Pub.dev)
- News (Hacker News, Reddit)
- Root level (YouTube, Wikipedia)

## Troubleshooting

### Import Not Working?
1. **Check file format** - Ensure it's an HTML file exported from a browser
2. **File size** - Very large bookmark files might take time to process
3. **Browser compatibility** - Try using Chrome for the web app
4. **Console errors** - Check browser developer tools for any JavaScript errors

### No Bookmarks Appearing?
1. **Check for duplicates** - The system prevents importing existing bookmarks
2. **Verify file content** - Open the HTML file in a text editor to ensure it contains bookmark data
3. **Folder filtering** - Make sure you're not filtering by a specific folder

### Performance Issues?
- Large bookmark files (1000+ bookmarks) may take a few seconds to import
- The app stores all data locally using Hive for offline functionality

## Conclusion

**The bookmark import functionality is already fully implemented and ready to use!** The Som Home app provides a complete solution for importing bookmarks from any major browser while maintaining folder organization and preventing duplicates.

No additional development is needed - users can immediately start importing their browser bookmarks using the existing import button in the bookmarks section.