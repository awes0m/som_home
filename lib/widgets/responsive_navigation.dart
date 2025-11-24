import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/responsive.dart';
import '../core/providers/auth_provider.dart';
import '../core/storage/hive_service.dart';

class ResponsiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestination> destinations;
  final List<String> titles;

  const ResponsiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return _buildMobileNavigation(context);
    } else {
      return _buildDesktopNavigation(context);
    }
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.9),
      elevation: 8,
    );
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: false,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.9),
      destinations: destinations
          .map(
            (dest) => NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: Text(dest.label),
            ),
          )
          .toList(),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Divider(),
                //Highlight the below text inside a box with rounded corners
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(titles[selectedIndex]),
                ),
                const Spacer(),
                _buildUserAvatar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated && auth.currentUser != null) {
          final display =
              auth.currentUser?.displayName ?? auth.currentUser?.email ?? '';
          final initial = display.isNotEmpty ? display[0].toUpperCase() : '?';

          return PopupMenuButton<String>(
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text(initial),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'info':
                  _showInfoDialog(context);
                  break;
                case 'help':
                  _showHelpDialog(context);
                  break;
                case 'sync':
                  await _syncData(context);
                  break;
                case 'signout':
                  _signOut(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Sync Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Information'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Badge(
            child: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.of(context).pushNamed('/sign-in'),
              tooltip: 'Sign In',
            ),
          );
        }
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Som Home'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A modern Flutter web app for your personal browser homepage.',
            ),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Google Search'),
            Text('• Bookmarks Management'),
            Text('• Task Tracking'),
            Text('• Mini Games'),
            Text('• Customizable Backgrounds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Tips:'),
            SizedBox(height: 8),
            Text('• Search bar auto-focuses on home page'),
            Text('• Mark bookmarks as favorites for quick access'),
            Text('• Import bookmarks from browser HTML exports'),
            Text('• Set custom backgrounds in Settings'),
            Text('• Tasks can have due dates and categories'),
            Text('• Games support keyboard and touch controls'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncData(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // 1. Capture the messenger immediately.
    // This looks up the widget tree NOW, while it's safe.
    final messenger = ScaffoldMessenger.of(context);

    if (auth.isAuthenticated) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Syncing data...'),
          duration: Duration(seconds: 2),
        ),
      );

      await HiveService.manualSync();

      // 2. Use the 'messenger' variable.
      // This does NOT require 'context' or 'mounted', so it won't crash.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sync completed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
