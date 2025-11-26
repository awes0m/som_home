import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/responsive.dart';
import '../core/providers/webview_provider.dart';
import '../tools/expense_manager_tool.dart';
import '../tools/json_formatter_tool.dart';
import '../tools/json_analyzer_tool.dart';
import '../tools/json_multi_correlator_tool.dart';


class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  String? _selectedTool;

  final List<ToolInfo> _tools = [
    ToolInfo(
      id: 'assets/expense_manger.html',
      title: 'Expense Manager',
      description: 'Track your expenses and manage your budget!',
      icon: Icons.money,
      color: Colors.teal,
      isWebview: false,
      isLocalAsset: true,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/numero_uno/',
      title: 'Numero Uno',
      description: 'Discover your destiny hidden in numbers!',
      icon: Icons.numbers_outlined,
      color: Colors.deepOrange,
      isWebview: true,
      isLocalAsset: false,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/fluttering_drums/',
      title: 'Fluttering Drums 🎼',
      description:
          ' An interactive web application that replicates the functionality of a digital drum machine',
      icon: Icons.music_note,
      color: Colors.blue,
      isWebview: false,
      isLocalAsset: false,
    ),

    ToolInfo(
      id: 'assets/smartJsonFormatterAnalyzer.html',
      title: 'Smart Json Formatter',
      description: 'Format JSON data and access various cybersecurity tools',
      icon: Icons.javascript_rounded,
      color: Colors.purple,
      isWebview: false,
      isLocalAsset: true,
    ),
    ToolInfo(
      id: 'assets/jsonCorelatorAnalyzer.html',
      title: 'Json Analyzer HQ',
      description: 'Format JSON data and access various cybersecurity tools',
      icon: Icons.cabin,
      color: Colors.lightGreen,
      isWebview: false,
      isLocalAsset: true,
    ),
    ToolInfo(
      id: 'assets/json_multi_corelator.html',
      title: 'Multi Json Corelator',
      description: 'Format JSON data and access various cybersecurity tools',
      icon: Icons.currency_bitcoin_rounded,
      color: Colors.lightGreen,
      isWebview: false,
      isLocalAsset: true,
    ),
    ToolInfo(
      id: 'https://awes0m.github.io/fortpolio/',
      title: 'More Tools',
      description: 'Explore additional web tools and utilities!',
      icon: Icons.more_horiz,
      color: Colors.blue,
      isWebview: true,
      isLocalAsset: false,
    ),
  ];

  Widget _buildToolWidget(String toolId) {
    switch (toolId) {
      case 'assets/expense_manger.html':
        return const ExpenseManagerTool();
      case 'assets/smartJsonFormatterAnalyzer.html':
        return const JsonFormatterTool();
      case 'assets/jsonCorelatorAnalyzer.html':
        return const JsonAnalyzerTool();
      case 'assets/json_multi_corelator.html':
        return const JsonMultiCorrelatorTool();
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
                        child: _buildToolWidget(_selectedTool!),
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
                  isWebview: tool.isWebview,
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
  final bool isWebview;
  final bool isLocalAsset;
  ToolInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isWebview = false,
    this.isLocalAsset = false,
  });
}

class _ToolCard extends StatelessWidget {
  final ToolInfo tool;
  final VoidCallback onTap;
  final bool isWebview;

  const _ToolCard({
    required this.tool,
    required this.onTap,
    this.isWebview = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: tool.isLocalAsset
            ? onTap
            : (isWebview)
                ? () {
                    final webViewProvider = Provider.of<WebViewProvider>(
                      context,
                      listen: false,
                    );
                    webViewProvider.openUrl(tool.id, title: tool.title);
                  }
                : () => launchUrl(Uri.parse(tool.id)),
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
