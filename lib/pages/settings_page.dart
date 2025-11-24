import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:web/web.dart' as web;
import '../core/providers/theme_provider.dart';
import '../core/providers/background_provider.dart';
import '../core/providers/bookmarks_provider.dart';
import '../core/providers/tasks_provider.dart';
import '../core/providers/greeting_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/storage/hive_service.dart';
import '../core/storage/backup_service.dart';
import '../core/utils/responsive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  BackupService? _backupService;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if this is the first time running
    if (_isInit) {
      final greetingProvider = Provider.of<GreetingProvider>(
        context,
        listen: false,
      );
      _nameController.text = greetingProvider.displayName;
      _isInit = false; // Ensure this only runs once
    }
  }

  @override
  void initState() {
    super.initState();
    _initBackupService();
    // No Future.delayed needed here anymore!
  }

  Future<void> _initBackupService() async {
    try {
      // Use existing opened boxes from HiveService instead of opening them again
      final bookmarksBox = HiveService.getBookmarksBox();
      final tasksBox = HiveService.getTasksBox();
      final settingsBox = HiveService.getSettingsBox();

      _backupService = BackupService(
        bookmarksBox: bookmarksBox,
        tasksBox: tasksBox,
        settingsBox: settingsBox,
      );
    } catch (e) {
      debugPrint('Error initializing backup service: $e');
      // If boxes are not available, we can still continue without backup functionality
      // The UI will handle errors when backup operations are attempted
    }
  }

  final List<String> defaultWallpapers = [
    'https://raw.githubusercontent.com/awes0m/fortpolio/refs/heads/main/artworks/DurgaSketch.jpg',
    'https://images.unsplash.com/photo-1761787769976-105d25e9d160',
    'https://images.unsplash.com/photo-1754851342161-083a48d2e075',
    'https://images.unsplash.com/photo-1468657988500-aca2be09f4c6',
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
      // Web-only image upload using HTML input element
      final uploadInput = web.HTMLInputElement()
        ..type = 'file'
        ..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.length == 0) return;

        final file = files.item(0)!;
        final reader = web.FileReader();

        reader.onLoadEnd.listen((e) async {
          try {
            final dataUrl = reader.result as String;
            if (mounted) {
              Provider.of<BackgroundProvider>(
                context,
                listen: false,
              ).setBackground(dataUrl, 'local');
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading image: $e')),
              );
            }
          }
        });

        reader.readAsDataURL(file);
      });
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

  Future<void> _syncToCloud(BuildContext context) async {
    try {
      final bookmarksProvider = Provider.of<BookmarksProvider>(
        context,
        listen: false,
      );
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Syncing to cloud...'),
            ],
          ),
        ),
      );

      await HiveService.syncBookmarksToCloud(bookmarksProvider.bookmarks);
      await HiveService.syncTasksToCloud(tasksProvider.tasks);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced to cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncFromCloud(BuildContext context) async {
    try {
      final bookmarksProvider = Provider.of<BookmarksProvider>(
        context,
        listen: false,
      );
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Downloading from cloud...'),
            ],
          ),
        ),
      );

      final bookmarks = await HiveService.loadBookmarksFromCloud();
      final tasks = await HiveService.loadTasksFromCloud();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        if (bookmarks.isEmpty && tasks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data found in cloud'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Update providers with cloud data
        if (bookmarks.isNotEmpty) {
          bookmarksProvider.setBookmarks(bookmarks);
        }
        if (tasks.isNotEmpty) {
          tasksProvider.setTasks(tasks);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data downloaded from cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSignOutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/sign-in', (route) => false);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // // Header
          // Container(
          //   padding: ResponsiveHelper.getResponsivePadding(context),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).brightness == Brightness.dark
          //         ? Colors.black.withValues(alpha: 0.3)
          //         : Colors.white.withValues(alpha: 0.7),
          //   ),
          //   child: Row(
          //     children: [
          //       Text(
          //         'Settings',
          //         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          //           fontWeight: FontWeight.bold,
          //           fontSize: ResponsiveHelper.getResponsiveFontSize(context, isMobile ? 28 : 32),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Settings
                      _SettingsSection(
                        title: 'Greeting',
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                16,
                              ),
                              vertical: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                8,
                              ),
                            ),
                            child: isMobile
                                ?
                                  // Mobile - vertical layout
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Display Name',
                                          hintText: 'Enter your name',
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              12,
                                            ),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          final name = _nameController.text
                                              .trim();
                                          Provider.of<GreetingProvider>(
                                            context,
                                            listen: false,
                                          ).setDisplayName(name);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Greeting name updated',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  )
                                :
                                  // Desktop - horizontal layout
                                  Row(
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
                                          final name = _nameController.text
                                              .trim();
                                          Provider.of<GreetingProvider>(
                                            context,
                                            listen: false,
                                          ).setDisplayName(name);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Greeting name updated',
                                              ),
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

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ), // Theme Settings
                      _SettingsSection(
                        title: 'Appearance',
                        children: [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return isMobile
                                  ?
                                    // Mobile - vertical layout for theme selector
                                    Padding(
                                      padding: EdgeInsets.all(
                                        ResponsiveHelper.getResponsiveSpacing(
                                          context,
                                          16,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Theme Mode',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontSize:
                                                      ResponsiveHelper.getResponsiveFontSize(
                                                        context,
                                                        16,
                                                      ),
                                                ),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.getResponsiveSpacing(
                                                  context,
                                                  8,
                                                ),
                                          ),
                                          Text(
                                            'Choose light, dark, or system theme',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize:
                                                      ResponsiveHelper.getResponsiveFontSize(
                                                        context,
                                                        14,
                                                      ),
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                                ),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.getResponsiveSpacing(
                                                  context,
                                                  12,
                                                ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: SegmentedButton<ThemeMode>(
                                              segments: [
                                                ButtonSegment(
                                                  value: ThemeMode.light,
                                                  icon: Icon(
                                                    Icons.light_mode,
                                                    size:
                                                        ResponsiveHelper.isMobile(
                                                          context,
                                                        )
                                                        ? 18
                                                        : 20,
                                                  ),
                                                  label: Text(
                                                    'Light',
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            context,
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                ButtonSegment(
                                                  value: ThemeMode.dark,
                                                  icon: Icon(
                                                    Icons.dark_mode,
                                                    size:
                                                        ResponsiveHelper.isMobile(
                                                          context,
                                                        )
                                                        ? 18
                                                        : 20,
                                                  ),
                                                  label: Text(
                                                    'Dark',
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            context,
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                ButtonSegment(
                                                  value: ThemeMode.system,
                                                  icon: Icon(
                                                    Icons.settings_suggest,
                                                    size:
                                                        ResponsiveHelper.isMobile(
                                                          context,
                                                        )
                                                        ? 18
                                                        : 20,
                                                  ),
                                                  label: Text(
                                                    'System',
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            context,
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              selected: {
                                                themeProvider.themeMode,
                                              },
                                              onSelectionChanged:
                                                  (
                                                    Set<ThemeMode> newSelection,
                                                  ) {
                                                    themeProvider.setThemeMode(
                                                      newSelection.first,
                                                    );
                                                  },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  :
                                    // Desktop - horizontal layout
                                    ListTile(
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

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

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
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile ? 2 : 4,
                                  crossAxisSpacing:
                                      ResponsiveHelper.getResponsiveSpacing(
                                        context,
                                        12,
                                      ),
                                  mainAxisSpacing:
                                      ResponsiveHelper.getResponsiveSpacing(
                                        context,
                                        12,
                                      ),
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

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Data Management
                      _SettingsSection(
                        title: 'Data',
                        children: [
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text('Export Configuration'),
                            subtitle: const Text(
                              'Download bookmarks, tasks, and settings as a JSON file',
                            ),
                            onTap: () async {
                              if (_backupService == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Backup service is not initialized',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              try {
                                await _backupService!.pickAndExportFile(
                                  context,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Configuration exported successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Export failed: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.upload),
                            title: const Text('Import Configuration'),
                            subtitle: const Text(
                              'Upload and load bookmarks, tasks, and settings from a JSON file',
                            ),
                            onTap: () async {
                              if (_backupService == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Backup service is not initialized',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              try {
                                await _backupService!.pickAndImportFile();
                                if (context.mounted) {
                                  // Notify providers to update UI
                                  Provider.of<BookmarksProvider>(
                                    context,
                                    listen: false,
                                  ).loadBookmarks();

                                  Provider.of<TasksProvider>(
                                    context,
                                    listen: false,
                                  ).loadTasks();

                                  Provider.of<BackgroundProvider>(
                                    context,
                                    listen: false,
                                  ).loadBackground();

                                  Provider.of<ThemeProvider>(
                                    context,
                                    listen: false,
                                  ).loadThemeMode();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Configuration imported successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Import failed: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
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

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Cloud Sync Section
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (!authProvider.isAuthenticated) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              _SettingsSection(
                                title: 'Cloud Sync',
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.cloud_upload),
                                    title: const Text('Sync to Cloud'),
                                    subtitle: const Text(
                                      'Upload bookmarks and tasks to Firebase',
                                    ),
                                    onTap: () => _syncToCloud(context),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.cloud_download),
                                    title: const Text('Sync from Cloud'),
                                    subtitle: const Text(
                                      'Download latest data from Firebase',
                                    ),
                                    onTap: () => _syncFromCloud(context),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  24,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Account Section
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return _SettingsSection(
                            title: 'Account',
                            children: [
                              if (authProvider.isAuthenticated) ...[
                                ListTile(
                                  leading: const Icon(Icons.account_circle),
                                  title: const Text('User Email'),
                                  subtitle: Text(
                                    authProvider.currentUser?.email ??
                                        'Not available',
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                  title: const Text('Sign Out'),
                                  subtitle: const Text(
                                    'Sign out from your account',
                                  ),
                                  onTap: () =>
                                      _showSignOutDialog(context, authProvider),
                                ),
                              ] else ...[
                                ListTile(
                                  leading: const Icon(Icons.login),
                                  title: const Text('Sign In'),
                                  subtitle: const Text(
                                    'Sign in to enable cloud sync',
                                  ),
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pushNamed('/sign-in'),
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

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
    final isMobile = ResponsiveHelper.isMobile(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveSpacing(context, 16),
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isMobile ? 18 : 20,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
