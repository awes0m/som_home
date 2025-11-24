import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../core/models/models.dart';
import '../core/providers/bookmarks_provider.dart';
import '../widgets/dialog_widget.dart';
import '../core/utils/url_validator.dart';
import '../core/utils/responsive.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String? _selectedFolder;
  final _searchController = TextEditingController();

  void _showImportDialog() async {
    final provider = Provider.of<BookmarksProvider>(context, listen: false);

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

        if (fileName.endsWith('.html')) {
          provider.importFromHtml(content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('HTML bookmarks imported successfully'),
              ),
            );
          }
        } else if (fileName.endsWith('.json')) {
          provider.importFromJson(content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('JSON bookmarks imported successfully'),
              ),
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

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
                padding: padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.3),
                ),
                child: isMobile
                    ? _buildMobileHeader(provider)
                    : _buildDesktopHeader(provider),
              ),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: isMobile ? 48 : 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No bookmarks found',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.grey.shade100,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          18,
                                        ),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : isMobile
                    ? _buildMobileBookmarksList(items, provider)
                    : _buildDesktopBookmarksList(items, provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: ResponsiveHelper.isMobile(context)
          ? FloatingActionButton(
              onPressed: () => _showAddOrEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMobileHeader(BookmarksProvider provider) {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search bookmarks...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        // Controls row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedFolder,
                decoration: const InputDecoration(
                  labelText: 'Folder',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All folders'),
                  ),
                  ...provider.folders.map(
                    (f) => DropdownMenuItem<String?>(value: f, child: Text(f)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedFolder = value),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _showImportDialog,
              icon: const Icon(Icons.file_upload),
              tooltip: 'Import',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BookmarksProvider provider) {
    return Row(
      children: [
        const Icon(Icons.bookmark),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search bookmarks...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String?>(
          value: _selectedFolder,
          hint: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder),
              SizedBox(width: 8),
              Text('All folders'),
            ],
          ),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.folder),
                  SizedBox(width: 8),
                  Text('All folders'),
                ],
              ),
            ),
            ...provider.folders.map(
              (f) => DropdownMenuItem<String?>(value: f, child: Text(f)),
            ),
          ],
          onChanged: (value) => setState(() => _selectedFolder = value),
        ),
        const SizedBox(width: 16),
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
    );
  }

  Widget _buildMobileBookmarksList(List items, BookmarksProvider provider) {
    return ListView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final b = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                b.isFavorite ? Icons.star : Icons.star_border,
                color: b.isFavorite ? Colors.amber : null,
                size: 20,
              ),
              onPressed: () => provider.toggleFavorite(b.id),
            ),
            title: Text(
              b.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              b.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton(
              iconSize: 20,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new, size: 18),
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
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                  onTap: () => _showAddOrEditDialog(b),
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                  onTap: () async {
                    final confirm = await ConfirmDialog.show(
                      context: context,
                      title: 'Delete Bookmark',
                      message: 'Are you sure you want to delete this bookmark?',
                      isDangerous: true,
                    );
                    if (confirm) {
                      provider.deleteBookmark(b.id);
                    }
                  },
                ),
              ],
            ),
            onTap: () => launchUrl(
              Uri.parse(b.url),
              mode: LaunchMode.externalApplication,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopBookmarksList(List items, BookmarksProvider provider) {
    final crossAxisCount = ResponsiveHelper.getCrossAxisCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return GridView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final b = items[index];
        return Card(
          child: InkWell(
            onTap: () => launchUrl(
              Uri.parse(b.url),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          b.isFavorite ? Icons.star : Icons.star_border,
                          color: b.isFavorite ? Colors.amber : null,
                          size: 20,
                        ),
                        onPressed: () => provider.toggleFavorite(b.id),
                      ),
                      Expanded(
                        child: Text(
                          b.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        iconSize: 20,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.open_in_new, size: 18),
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
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                            onTap: () => _showAddOrEditDialog(b),
                          ),
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, size: 18),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      b.url,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (b.folder != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        b.folder!,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
