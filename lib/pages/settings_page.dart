import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../core/providers/theme_provider.dart';
import '../core/providers/background_provider.dart';
import '../core/providers/bookmarks_provider.dart';
import '../core/providers/tasks_provider.dart';
import '../core/providers/greeting_provider.dart';
import '../core/storage/hive_service.dart';
import '../core/storage/backup_service.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late BackupService _backupService;

  @override
  void initState() {
    super.initState();
    _initBackupService();
    Future.delayed(Duration.zero, () {
      final greetingProvider = Provider.of<GreetingProvider>(
        context,
        listen: false,
      );
      _nameController.text = greetingProvider.displayName;
    });
  }

  Future<void> _initBackupService() async {
    final bookmarksBox = await Hive.openBox('bookmarks_box');
    final tasksBox = await Hive.openBox('tasks_box');
    final settingsBox = await Hive.openBox('settings_box');
    _backupService = BackupService(
      bookmarksBox: bookmarksBox,
      tasksBox: tasksBox,
      settingsBox: settingsBox,
    );
  }

  final List<String> defaultWallpapers = [
    'https://images.unsplash.com/photo-1519681393784-d120267933ba',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
    'https://images.unsplash.com/photo-1501594907352-04cda38ebc29',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
  ];

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Background URL'),
        content: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                Provider.of<BackgroundProvider>(
                  context,
                  listen: false,
                ).setBackground(url, 'url');
                Navigator.pop(context);
                _urlController.clear();
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocalImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final base64Image = base64Encode(bytes);
        final dataUrl = 'data:image/png;base64,$base64Image';

        if (mounted) {
          Provider.of<BackgroundProvider>(
            context,
            listen: false,
          ).setBackground(dataUrl, 'local');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading image: $e')));
      }
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'This will delete all bookmarks and tasks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await HiveService.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been reset')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.7),
            ),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Settings
                      _SettingsSection(
                        title: 'Greeting',
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Display Name',
                                      hintText: 'Enter your name',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: () {
                                    final name = _nameController.text.trim();
                                    Provider.of<GreetingProvider>(
                                      context,
                                      listen: false,
                                    ).setDisplayName(name);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Greeting name updated'),
                                      ),
                                    );
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Theme Settings
                      _SettingsSection(
                        title: 'Appearance',
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return ListTile(
                                title: const Text('Theme Mode'),
                                subtitle: const Text(
                                  'Choose light, dark, or system theme',
                                ),
                                trailing: SegmentedButton<ThemeMode>(
                                  segments: const [
                                    ButtonSegment(
                                      value: ThemeMode.light,
                                      icon: Icon(Icons.light_mode),
                                    ),
                                    ButtonSegment(
                                      value: ThemeMode.dark,
                                      icon: Icon(Icons.dark_mode),
                                    ),
                                    ButtonSegment(
                                      value: ThemeMode.system,
                                      icon: Icon(Icons.settings_suggest),
                                    ),
                                  ],
                                  selected: {themeProvider.themeMode},
                                  onSelectionChanged:
                                      (Set<ThemeMode> newSelection) {
                                        themeProvider.setThemeMode(
                                          newSelection.first,
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Background Settings
                      _SettingsSection(
                        title: 'Background',
                        children: [
                          ListTile(
                            leading: const Icon(Icons.link),
                            title: const Text('Set from URL'),
                            subtitle: const Text('Enter an image URL'),
                            onTap: _showUrlDialog,
                          ),
                          ListTile(
                            leading: const Icon(Icons.upload_file),
                            title: const Text('Upload Local Image'),
                            subtitle: const Text(
                              'Choose an image from your device',
                            ),
                            onTap: _pickLocalImage,
                          ),
                          ListTile(
                            leading: const Icon(Icons.clear),
                            title: const Text('Clear Background'),
                            subtitle: const Text('Use default gradient'),
                            onTap: () {
                              Provider.of<BackgroundProvider>(
                                context,
                                listen: false,
                              ).clearBackground();
                            },
                          ),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Default Wallpapers',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: defaultWallpapers.length,
                            itemBuilder: (context, index) {
                              final url = defaultWallpapers[index];
                              return InkWell(
                                onTap: () {
                                  Provider.of<BackgroundProvider>(
                                    context,
                                    listen: false,
                                  ).setBackground(url, 'preset');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Data Management
                      _SettingsSection(
                        title: 'Data',
                        children: [
                          ListTile(
                            leading: const Icon(Icons.upload_file),
                            title: const Text('Export Configuration'),
                            subtitle: const Text(
                              'Save bookmarks, tasks, and settings to a JSON file',
                            ),
                            onTap: () async {
                              await _backupService.pickAndExportFile(context);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Configuration exported!'),
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text('Import Configuration'),
                            subtitle: const Text(
                              'Load bookmarks, tasks, and settings from a JSON file',
                            ),
                            onTap: () async {
                              await _backupService.pickAndImportFile();
                              if (context.mounted) {
                                // Notify providers to update UI
                                if (context.mounted) {
                                  Provider.of<BookmarksProvider>(
                                    context,
                                    listen: false,
                                  ).loadBookmarks();
                                }
                                if (context.mounted) {
                                  Provider.of<TasksProvider>(
                                    context,
                                    listen: false,
                                  ).loadTasks();
                                }
                                if (context.mounted) {
                                  Provider.of<BackgroundProvider>(
                                    context,
                                    listen: false,
                                  ).loadBackground();
                                }
                                if (context.mounted) {
                                  Provider.of<ThemeProvider>(
                                    context,
                                    listen: false,
                                  ).loadThemeMode();
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Configuration imported!'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            title: const Text('Reset All Data'),
                            subtitle: const Text(
                              'Delete all bookmarks and tasks',
                            ),
                            onTap: _showResetDialog,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About
                      const _SettingsSection(
                        title: 'About',
                        children: [
                          ListTile(
                            leading: Icon(Icons.info),
                            title: Text('Personal Homepage'),
                            subtitle: Text('Version 1.0.0'),
                          ),
                          ListTile(
                            leading: Icon(Icons.code),
                            title: Text('Built with Flutter'),
                            subtitle: Text('Modern web application'),
                            trailing: Chip(
                              label: Text('Flutter Web'),
                              avatar: Icon(Icons.flutter_dash, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
