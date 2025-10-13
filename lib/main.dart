import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/background_provider.dart';
import 'core/providers/bookmarks_provider.dart';
import 'core/providers/tasks_provider.dart';
import 'core/providers/greeting_provider.dart';
import 'core/storage/hive_service.dart';
import 'pages/homepage.dart';
import 'pages/bookmarks_page.dart';
import 'pages/tasks_page.dart';
import 'pages/games_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
            home: const MainNavigation(),
          );
        },
      ),
    );
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
