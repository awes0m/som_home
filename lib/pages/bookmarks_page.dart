import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../core/models/models.dart';
import '../core/providers/bookmarks_provider.dart';
import '../widgets/dialog_widget.dart';
import '../core/utils/url_validator.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String? _selectedFolder;
  final _searchController = TextEditingController();

  void _showImportDialog() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        final fileName = result.files.single.name.toLowerCase();
        
        final provider = Provider.of<BookmarksProvider>(context, listen: false);
        
        if (fileName.endsWith('.html')) {
          provider.importFromHtml(content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('HTML bookmarks imported successfully')),
            );
          }
        } else if (fileName.endsWith('.json')) {
          provider.importFromJson(content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('JSON bookmarks imported successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing bookmarks: $e')),
        );
      }
    }
  }

  void _showAddOrEditDialog([Bookmark? bookmark]) async {
    final titleController = TextEditingController(text: bookmark?.title ?? '');
    final urlController = TextEditingController(text: bookmark?.url ?? '');
    final folderController = TextEditingController(
      text: bookmark?.folder ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookmark == null ? 'Add Bookmark' : 'Edit Bookmark'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title*'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL*'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: folderController,
                decoration: const InputDecoration(labelText: 'Folder'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              var url = urlController.text.trim();
              if (title.isEmpty || url.isEmpty) return;
              if (!UrlValidator.isValidUrl(url)) {
                url = UrlValidator.ensureHttps(url);
              }
              final provider = Provider.of<BookmarksProvider>(
                context,
                listen: false,
              );
              if (bookmark == null) {
                provider.addBookmark(
                  Bookmark(
                    title: title,
                    url: url,
                    folder: folderController.text.trim().isEmpty
                        ? null
                        : folderController.text.trim(),
                  ),
                );
              } else {
                bookmark.title = title;
                bookmark.url = url;
                bookmark.folder = folderController.text.trim().isEmpty
                    ? null
                    : folderController.text.trim();
                provider.updateBookmark(bookmark);
              }
              Navigator.pop(context, true);
            },
            child: Text(bookmark == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bookmark == null ? 'Bookmark added' : 'Bookmark updated',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<BookmarksProvider>(
        builder: (context, provider, _) {
          final items = provider.bookmarks
              .where((b) {
                final q = _searchController.text.toLowerCase();
                if (q.isEmpty) return true;
                return b.title.toLowerCase().contains(q) ||
                    b.url.toLowerCase().contains(q);
              })
              .where(
                (b) =>
                    _selectedFolder == null ||
                    _selectedFolder!.isEmpty ||
                    b.folder == _selectedFolder,
              )
              .toList();

          return Column(
            children: [
              // Header and controls
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.7),
                ),
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.bookmark),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String?>(
                        value: _selectedFolder,
                        hint: const Icon(Icons.folder),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem(
                            value: null,
                            child:  Icon(Icons.folder),
                          ),
                          ...provider.folders.map(
                            (f) => DropdownMenuItem<String?>(
                              value: f,
                              child: Text(f),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedFolder = value),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _showImportDialog,
                        icon: const Icon(Icons.file_upload),
                        tooltip: 'Import bookmarks (HTML/JSON)',
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _showAddOrEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No bookmarks found',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final b = items[index];
                          return Card(
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(
                                  b.isFavorite ? Icons.star : Icons.star_border,
                                  color: b.isFavorite ? Colors.amber : null,
                                ),
                                onPressed: () => provider.toggleFavorite(b.id),
                              ),
                              title: Text(b.title),
                              subtitle: Text(
                                b.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.open_in_new, size: 20),
                                        SizedBox(width: 8),
                                        Text('Open'),
                                      ],
                                    ),
                                    onTap: () => launchUrl(
                                      Uri.parse(b.url),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                    onTap: () => _showAddOrEditDialog(b),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                    onTap: () async {
                                      final confirm = await ConfirmDialog.show(
                                        context: context,
                                        title: 'Delete Bookmark',
                                        message:
                                            'Are you sure you want to delete this bookmark?',
                                        isDangerous: true,
                                      );
                                      if (confirm) {
                                        provider.deleteBookmark(b.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
