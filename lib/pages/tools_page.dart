import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/responsive.dart';
import '../core/providers/webview_provider.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  String? _selectedTool;

  final List<ToolInfo> _tools = [
    ToolInfo(
      id: 'https://awes0m.github.io/expense_tracker/',
      title: 'Expense Tracker',
      description: 'Track your expenses and manage your budget!',
      icon: Icons.money,
      color: Colors.teal,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/numero_uno/',
      title: 'Numero Uno',
      description: 'Discover your destiny hidden in numbers!',
      icon: Icons.numbers_outlined,
      color: Colors.indigoAccent,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/fluttering_drums/',
      title: 'Fluttering Drums 🎼',
      description:
          ' An interactive web application that replicates the functionality of a digital drum machine',
      icon: Icons.music_note,
      color: Colors.blue,
    ),

    ToolInfo(
      id: 'https://awes0m.github.io/cybersec_tools/',
      title: 'Json Formatter and Cybersec Tools',
      description: 'Format JSON data and access various cybersecurity tools',
      icon: Icons.currency_bitcoin_rounded,
      color: Colors.purple,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/fortpolio/',
      title: 'More Tools',
      description: 'Explore additional web tools and utilities!',
      icon: Icons.casino,
      color: Colors.orange,
    ),
  ];

  Widget _buildGameWidget(String gameId) {
    switch (gameId) {
      // case 'snake':
      //   return const SnakeGame();
      // case 'rps':
      //   return const RockPaperScissorsGame();
      // case '2048':
      //   return const Game2048();
      // case 'tictactoe':
      //   return const TicTacToeGame();
      // case 'memory':
      //   return const MemoryMatchGame();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_selectedTool != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          title: Text(
            _tools.firstWhere((g) => g.id == _selectedTool).title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                isMobile ? 18 : 20,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: isMobile ? 20 : 24),
            onPressed: () => setState(() => _selectedTool = null),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double maxContentWidth = ResponsiveHelper.getMaxContentWidth(
              context,
            );
            final Color surfaceColor =
                Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.7);

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: surfaceColor,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _buildGameWidget(_selectedTool!),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: ResponsiveHelper.getResponsivePadding(context),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isMobile ? 200 : 300,
                crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  16,
                ),
                mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  16,
                ),
                childAspectRatio: isMobile ? 0.85 : 0.8,
              ),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                return _ToolCard(
                  tool: tool,
                  isLink: tool.isLink,
                  onTap: () => setState(() => _selectedTool = tool.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ToolInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLink;
  ToolInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLink = true,
  });
}

class _ToolCard extends StatelessWidget {
  final ToolInfo tool;
  final VoidCallback onTap;
  final bool isLink;

  const _ToolCard({
    required this.tool,
    required this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (isLink)
            ? () {
                final webViewProvider = Provider.of<WebViewProvider>(
                  context,
                  listen: false,
                );
                webViewProvider.openUrl(tool.id, title: tool.title);
              }
            : onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tool.color.withValues(alpha: 0.7),
                tool.color.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool.icon, size: isMobile ? 48 : 64, color: Colors.white),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 16),
                ),
                Text(
                  tool.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isMobile ? 16 : 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                ),
                Text(
                  tool.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
