import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/background_provider.dart';
import 'core/providers/bookmarks_provider.dart';
import 'core/providers/tasks_provider.dart';
import 'core/providers/greeting_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/responsive.dart';
import 'widgets/responsive_navigation.dart';
import 'pages/homepage.dart';
import 'pages/bookmarks_page.dart';
import 'pages/tasks_page.dart';
import 'pages/games_page.dart';
import 'pages/settings_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/forgot_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider(
      '6Lc4ww0sAAAAADMrg8WuqQF9C4rVkmw5ikZEO9iF',
    ), //recaptcha-v3-site-key
  );
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BackgroundProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => GreetingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Personal Homepage',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: theme.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/home': (context) => const MainNavigation(),
              '/sign-in': (context) => const SignInPage(),
              '/sign-up': (context) => const SignUpPage(),
              '/forgot-password': (context) => const ForgotPasswordPage(),
            },
          );
        },
      ),
    );
  }
}

// Auth wrapper to handle navigation based on auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _promptShown = false;

  void _maybeShowSignInPrompt(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Use settings box to persist that user has seen the prompt
    final settingsBox = HiveService.getSettingsBox();
    final alreadyPrompted = settingsBox.get('prompt_signin_shown') == true;

    if (_promptShown || alreadyPrompted) return;

    if (authProvider.currentUser == null) {
      _promptShown = true;
      // schedule after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Sign in to backup and sync your data across devices. Use the account icon in the navigation bar.',
            ),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                settingsBox.put('prompt_signin_shown', true);
              },
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show main navigation; Auth UI is available via top-right avatar
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowSignInPrompt(context),
    );
    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final _pages = const [
    HomePage(),
    BookmarksPage(),
    TasksPage(),
    GamesPage(),
    SettingsPage(),
  ];
  final _titles = const ['Home', 'Bookmarks', 'Tasks', 'Games', 'Settings'];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      label: 'Bookmarks',
    ),
    NavigationDestination(
      icon: Icon(Icons.checklist_outlined),
      selectedIcon: Icon(Icons.checklist),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.videogame_asset_outlined),
      selectedIcon: Icon(Icons.videogame_asset),
      label: 'Games',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = context.watch<BackgroundProvider>();
    BoxDecoration background;
    if (bg.backgroundType == 'url' || bg.backgroundType == 'preset') {
      background = BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            bg.backgroundUrl ??
                'https://images.unsplash.com/photo-1754851342161-083a48d2e075',
          ),
          fit: BoxFit.cover,
        ),
      );
    } else if (bg.backgroundType == 'local') {
      background = BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(bg.backgroundUrl ?? ''),
          fit: BoxFit.cover,
        ),
      );
    } else {
      background = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.6),
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          ],
        ),
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Container(
        decoration: background,
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
      bottomNavigationBar: isMobile
          ? ResponsiveNavigation(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: _destinations,
              titles: _titles,
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          // Mobile app bar
          if (_index != 0) // Don't show app bar on home page for cleaner look
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    _titles[_index],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildMobileUserAvatar(),
                ],
              ),
            ),
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        ResponsiveNavigation(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: _destinations,
          titles: _titles,
        ),
        Expanded(
          child: Column(
            children: [
              // Desktop app bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Text(
                      _titles[_index],
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // Desktop user avatar is handled in ResponsiveNavigation
                  ],
                ),
              ),
              Expanded(child: _pages[_index]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileUserAvatar() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated && auth.currentUser != null) {
          final display =
              auth.currentUser?.displayName ?? auth.currentUser?.email ?? '';
          final initial = display.isNotEmpty ? display[0].toUpperCase() : '?';

          return PopupMenuButton<String>(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text(initial, style: const TextStyle(fontSize: 14)),
            ),
            onSelected: (value) {
              switch (value) {
                case 'sync':
                  _syncData(context);
                  break;
                case 'signout':
                  _signOut(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 20),
                    SizedBox(width: 8),
                    Text('Sync Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
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
        title: const Text('About Personal Homepage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A modern Flutter web application that serves as a personal browser homepage with the following features:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text('• Google Search integration'),
            Text('• Bookmark management'),
            Text('• Task tracking'),
            Text('• Customizable backgrounds'),
            Text('• Mini-games (Snake, Flappy Bird, etc.)'),
            Text('• Offline-first functionality'),
            SizedBox(height: 12),
            Text(
              'Built with Flutter and Firebase for cross-device synchronization.',
              style: TextStyle(fontSize: 14),
            ),
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
            Text(
              'Getting Started:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Use the navigation icons to switch between pages'),
            Text('• Click the search icon to access Google Search'),
            Text('• Tap your profile avatar to access settings'),
            SizedBox(height: 12),
            Text(
              'Sync & Backup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Sign in to backup your data across devices'),
            Text('• Use the Sync Data option to manually sync'),
            Text('• Your bookmarks and tasks are automatically saved locally'),
            SizedBox(height: 12),
            Text(
              'Customization:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Change themes in Settings'),
            Text('• Set custom backgrounds (URL, local image, or presets)'),
            Text('• Organize bookmarks into folders'),
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

  void _syncData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to sync your data')),
      );
      return;
    }

    try {
      await HiveService.mergeLocalAndCloudOnSignIn();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synced successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: ${e.toString()}')));
      }
    }
  }

  void _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    }
  }
}
