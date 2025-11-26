import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../core/providers/webview_provider.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Map<String, InAppWebViewController?> _controllers = {};
  final Map<String, bool> _canGoBack = {};
  final Map<String, bool> _canGoForward = {};

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
            Expanded(child: _buildWebViewContent(webViewProvider)),
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No web pages open',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a bookmark or enter a URL to browse websites',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
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
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tab.title,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _handleCloseTab(provider, tab.id),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
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

    final canGoBack = _canGoBack[currentTab.id] ?? false;
    final canGoForward = _canGoForward[currentTab.id] ?? false;
    final controller = _controllers[currentTab.id];

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoBack
                ? () async {
                    await controller?.goBack();
                    await _updateNavigationState(currentTab.id);
                  }
                : null,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Back',
          ),
          IconButton(
            onPressed: canGoForward
                ? () async {
                    await controller?.goForward();
                    await _updateNavigationState(currentTab.id);
                  }
                : null,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: 'Forward',
          ),
          IconButton(
            onPressed: controller == null
                ? null
                : () async {
                    await controller.reload();
                    provider.updateTabLoading(currentTab.id, true);
                  },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _handleCloseTab(provider, currentTab.id),
            icon: const Icon(Icons.close),
            tooltip: 'Close tab',
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent(WebViewProvider provider) {
    final tabs = provider.tabs;
    if (tabs.isEmpty) return const SizedBox.shrink();
    _pruneOrphanedState(tabs);
    final index = provider.currentTabIndex < 0
        ? 0
        : provider.currentTabIndex >= tabs.length
        ? tabs.length - 1
        : provider.currentTabIndex;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: IndexedStack(
        index: index,
        children: tabs.map((tab) => _buildInAppWebView(provider, tab)).toList(),
      ),
    );
  }

  Widget _buildInAppWebView(WebViewProvider provider, WebViewTab tab) {
    return InAppWebView(
      key: ValueKey('webview-${tab.id}'),
      initialUrlRequest: URLRequest(url: WebUri(tab.url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        allowsBackForwardNavigationGestures: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        setState(() {
          _controllers[tab.id] = controller;
        });
        _updateNavigationState(tab.id);
      },
      onLoadStart: (controller, url) {
        provider.updateTabLoading(tab.id, true);
      },
      onLoadStop: (controller, url) async {
        provider.updateTabLoading(tab.id, false);
        if (url != null) {
          provider.updateTabUrl(tab.id, url.toString());
        }
        await _updateNavigationState(tab.id);
      },
      onReceivedError: (controller, request, error) {
        provider.updateTabLoading(tab.id, false);
      },
      onTitleChanged: (controller, title) {
        if (title != null && title.trim().isNotEmpty) {
          provider.updateTabTitle(tab.id, title);
        }
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        if (url != null) {
          provider.updateTabUrl(tab.id, url.toString());
        }
      },
    );
  }

  Future<void> _updateNavigationState(String tabId) async {
    final controller = _controllers[tabId];
    if (controller == null) return;
    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack[tabId] = canGoBack;
      _canGoForward[tabId] = canGoForward;
    });
  }

  void _handleCloseTab(WebViewProvider provider, String tabId) {
    setState(() {
      _controllers.remove(tabId);
      _canGoBack.remove(tabId);
      _canGoForward.remove(tabId);
    });
    provider.closeTab(tabId);
  }

  void _pruneOrphanedState(List<WebViewTab> tabs) {
    final validIds = tabs.map((tab) => tab.id).toSet();
    final hasOrphan =
        _controllers.keys.any((id) => !validIds.contains(id)) ||
        _canGoBack.keys.any((id) => !validIds.contains(id)) ||
        _canGoForward.keys.any((id) => !validIds.contains(id));
    if (!hasOrphan) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _controllers.removeWhere((key, value) => !validIds.contains(key));
        _canGoBack.removeWhere((key, value) => !validIds.contains(key));
        _canGoForward.removeWhere((key, value) => !validIds.contains(key));
      });
    });
  }
}
