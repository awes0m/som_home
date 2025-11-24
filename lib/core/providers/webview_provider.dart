import 'package:flutter/material.dart';

class WebViewTab {
  final String id;
  final String title;
  final String url;
  final bool isLoading;

  WebViewTab({
    required this.id,
    required this.title,
    required this.url,
    this.isLoading = false,
  });

  WebViewTab copyWith({
    String? id,
    String? title,
    String? url,
    bool? isLoading,
  }) {
    return WebViewTab(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WebViewProvider extends ChangeNotifier {
  final List<WebViewTab> _tabs = [];
  int _currentTabIndex = -1;
  Function(int)? _onTabOpened;

  List<WebViewTab> get tabs => List.unmodifiable(_tabs);
  int get currentTabIndex => _currentTabIndex;
  WebViewTab? get currentTab => 
      _currentTabIndex >= 0 && _currentTabIndex < _tabs.length 
          ? _tabs[_currentTabIndex] 
          : null;
  bool get hasOpenTabs => _tabs.isNotEmpty;

  void setOnTabOpenedCallback(Function(int) callback) {
    _onTabOpened = callback;
  }

  String _generateTabId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void openUrl(String url, {String? title}) {
    final tabId = _generateTabId();
    final tab = WebViewTab(
      id: tabId,
      title: title ?? _extractDomainFromUrl(url),
      url: url,
      isLoading: true,
    );

    _tabs.add(tab);
    _currentTabIndex = _tabs.length - 1;
    notifyListeners();
    
    // Notify the navigation to switch to webview tab (index 1 when tabs are open)
    if (_onTabOpened != null) {
      _onTabOpened!(1);
    }
  }

  void closeTab(String tabId) {
    final index = _tabs.indexWhere((tab) => tab.id == tabId);
    if (index == -1) return;

    _tabs.removeAt(index);
    
    if (_currentTabIndex >= _tabs.length) {
      _currentTabIndex = _tabs.length - 1;
    } else if (_currentTabIndex == index && _tabs.isNotEmpty) {
      // If we closed the current tab, stay at the same index if possible
      if (_currentTabIndex >= _tabs.length) {
        _currentTabIndex = _tabs.length - 1;
      }
    }
    
    notifyListeners();
  }

  void switchToTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void updateTabTitle(String tabId, String title) {
    final index = _tabs.indexWhere((tab) => tab.id == tabId);
    if (index != -1) {
      _tabs[index] = _tabs[index].copyWith(title: title);
      notifyListeners();
    }
  }

  void updateTabLoading(String tabId, bool isLoading) {
    final index = _tabs.indexWhere((tab) => tab.id == tabId);
    if (index != -1) {
      _tabs[index] = _tabs[index].copyWith(isLoading: isLoading);
      notifyListeners();
    }
  }

  void updateTabUrl(String tabId, String url) {
    final index = _tabs.indexWhere((tab) => tab.id == tabId);
    if (index != -1) {
      _tabs[index] = _tabs[index].copyWith(url: url);
      notifyListeners();
    }
  }

  void closeAllTabs() {
    _tabs.clear();
    _currentTabIndex = -1;
    notifyListeners();
  }

  String _extractDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (e) {
      return url;
    }
  }
}