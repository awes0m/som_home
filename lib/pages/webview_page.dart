import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import '../core/providers/webview_provider.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Map<String, String> _iframeViewTypes = {};

  @override
  void initState() {
    super.initState();
  }

  void _registerIframe(String tabId, String url) {
    if (!_iframeViewTypes.containsKey(tabId)) {
      final viewType = 'iframe-$tabId';
      _iframeViewTypes[tabId] = viewType;
      
      // Register the iframe element
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..src = url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
          
          // Listen for load events to update loading state
          iframe.onLoad.listen((_) {
            final provider = context.read<WebViewProvider>();
            provider.updateTabLoading(tabId, false);
            
            // Note: Cannot access iframe content due to CORS restrictions
            // Title will remain as the URL or be set externally
          });
          
          return iframe;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebViewProvider>(
      builder: (context, webViewProvider, child) {
        if (!webViewProvider.hasOpenTabs) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            if (webViewProvider.tabs.length > 1) _buildTabBar(webViewProvider),
            _buildWebViewControls(webViewProvider),
            Expanded(
              child: _buildWebViewContent(webViewProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.web,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No web pages open',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a bookmark or enter a URL to browse websites',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(WebViewProvider provider) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.tabs.length,
        itemBuilder: (context, index) {
          final tab = provider.tabs[index];
          final isActive = index == provider.currentTabIndex;
          
          return Container(
            constraints: const BoxConstraints(maxWidth: 200, minWidth: 120),
            child: Material(
              color: isActive 
                  ? Theme.of(context).colorScheme.surface
                  : Colors.transparent,
              child: InkWell(
                onTap: () => provider.switchToTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (tab.isLoading)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.web,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tab.title,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => provider.closeTab(tab.id),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebViewControls(WebViewProvider provider) {
    final currentTab = provider.currentTab;
    if (currentTab == null) return const SizedBox.shrink();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Refresh functionality - recreate iframe
              _iframeViewTypes.remove(currentTab.id);
              provider.updateTabLoading(currentTab.id, true);
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentTab.url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => provider.closeTab(currentTab.id),
            icon: const Icon(Icons.close),
            tooltip: 'Close tab',
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent(WebViewProvider provider) {
    final currentTab = provider.currentTab;
    if (currentTab == null) return const SizedBox.shrink();

    _registerIframe(currentTab.id, currentTab.url);
    final viewType = _iframeViewTypes[currentTab.id]!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: HtmlElementView(
        viewType: viewType,
      ),
    );
  }
}