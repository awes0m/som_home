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
import 'core/providers/auth_provider.dart' ;
import 'core/storage/hive_service.dart';
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keep your data safe'),
            content: const Text(
              'Sign in to backup and sync your bookmarks, tasks and settings across devices.\n\nWould you like to sign in now?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  settingsBox.put('prompt_signin_shown', true);
                  Navigator.of(context).pop();
                },
                child: const Text('Maybe later'),
              ),
              FilledButton(
                onPressed: () {
                  settingsBox.put('prompt_signin_shown', true);
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/sign-in');
                },
                child: const Text('Sign in'),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final bg = context.watch<BackgroundProvider>();
    BoxDecoration background;
    if (bg.backgroundType == 'url' || bg.backgroundType == 'preset') {
      background = BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(bg.backgroundUrl ?? ''),
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

    return Scaffold(
      body: Container(
        decoration: background,
        child: Column(
          children: [
            // Top app bar
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 0),
                      icon: const Icon(Icons.home, size: 32),

                      tooltip: 'Home',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _titles[_index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 0),
                      icon: const Icon(Icons.search),
                      tooltip: 'Home',
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 1),
                      icon: const Icon(Icons.bookmark),
                      tooltip: 'Bookmarks',
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 2),
                      icon: const Icon(Icons.checklist),
                      tooltip: 'Tasks',
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 3),
                      icon: const Icon(Icons.videogame_asset),
                      tooltip: 'Games',
                    ),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => setState(() => _index = 4),
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                    ),
                    const SizedBox(width: 8),
                    // Login / Profile avatar
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.isAuthenticated && auth.currentUser != null) {
                          final display =
                              auth.currentUser?.displayName ??
                              auth.currentUser?.email ??
                              '';
                          final initial = display.isNotEmpty
                              ? display[0].toUpperCase()
                              : '?';
                          return GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/settings'),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              child: Text(initial),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/sign-in'),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              child: Icon(Icons.person),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _pages[_index]),
          ],
        ),
      ),
    );
  }
}
