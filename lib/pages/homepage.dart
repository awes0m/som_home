import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/providers/bookmarks_provider.dart';
import '../core/providers/greeting_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentTime = '';
  String _currentDate = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateTime();
    });
    Future.delayed(Duration.zero, () {
      _searchFocusNode.requestFocus();
    });
  }

  void _updateTime() {
    setState(() {
      final now = DateTime.now();
      _currentTime = DateFormat('HH:mm').format(now);
      _currentDate = DateFormat('EEEE, MMMM d, y').format(now);
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final url = Uri.parse(
        'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
      );
      launchUrl(url, mode: LaunchMode.externalApplication);
      _searchController.clear();
    }
  }

  String _buildGreeting(String displayName) {
    final hour = DateTime.now().hour;
    String salutation;
    if (hour >= 5 && hour < 12) {
      salutation = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      salutation = 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      salutation = 'Good evening';
    } else {
      salutation = 'Night owl';
    }
    return '$salutation, $displayName!';
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    final favorites = bookmarksProvider.favorites.take(8).toList();
    final greetingProvider = Provider.of<GreetingProvider>(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _buildGreeting(greetingProvider.displayName),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 40,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              // Time & Date
              Text(
                _currentTime,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentDate,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Google Search Bar
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search Google or type a URL',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.search),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              // Favorite Bookmarks
              if (favorites.isNotEmpty) ...[
                const SizedBox(height: 60),
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: favorites.map((bookmark) {
                          return InkWell(
                            onTap: () {
                              final url = Uri.parse(bookmark.url);
                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bookmark.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
