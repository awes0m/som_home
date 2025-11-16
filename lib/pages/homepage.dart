import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/providers/bookmarks_provider.dart';
import '../core/providers/greeting_provider.dart';
import '../core/utils/responsive.dart';

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
    
    final isMobile = ResponsiveHelper.isMobile(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding:padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greeting
                Text(
                  _buildGreeting(greetingProvider.displayName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isMobile ? 28 : 40),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isMobile ? 16 : 24),
                
                // Time & Date
                Text(
                  _currentTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isMobile ? 48 : 72),
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
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isMobile ? 16 : 20),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isMobile ? 40 : 60),

                // Google Search Bar
                Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 600,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: isMobile ? 10 : 20,
                        spreadRadius: isMobile ? 1 : 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: (_) => _performSearch(),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                    decoration: InputDecoration(
                      hintText: isMobile ? 'Search Google...' : 'Search Google or type a URL',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                        child: Icon(Icons.search, size: isMobile ? 20 : 24),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, size: isMobile ? 20 : 24),
                        onPressed: _performSearch,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: isMobile ? 12 : 16,
                      ),
                    ),
                  ),
                ),

                // Favorite Bookmarks
                if (favorites.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 40 : 60),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 800,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: isMobile ? 5 : 10,
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
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, isMobile ? 18 : 22),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildFavoritesGrid(context, favorites, isMobile),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(BuildContext context, List favorites, bool isMobile) {
    final crossAxisCount = ResponsiveHelper.getCrossAxisCount(
      context,
      mobile: 4,
      tablet: 6,
      desktop: 8,
    );
    
    if (isMobile) {
      // Use GridView for mobile to ensure proper spacing
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return _buildFavoriteItem(context, favorites[index], isMobile);
        },
      );
    } else {
      // Use Wrap for desktop/tablet
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: favorites.map<Widget>((bookmark) {
          return _buildFavoriteItem(context, bookmark, isMobile);
        }).toList(),
      );
    }
  }

  Widget _buildFavoriteItem(BuildContext context, bookmark, bool isMobile) {
    return InkWell(
      onTap: () {
        final url = Uri.parse(bookmark.url);
        launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      },
      child: Container(
        width: isMobile ? null : 80,
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.primary,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              bookmark.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: isMobile ? 10 : 12,
              ),
            ),
          ],
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
