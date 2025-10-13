import 'package:flutter/material.dart';
import '../storage/hive_service.dart';

class GreetingProvider with ChangeNotifier {
  static const String _storageKey = 'greeting_display_name';
  static const String _defaultName = 'Som';

  String _displayName = _defaultName;

  GreetingProvider() {
    _loadName();
  }

  String get displayName => _displayName;

  void _loadName() {
    final box = HiveService.getSettingsBox();
    final stored = box.get(_storageKey, defaultValue: _defaultName);
    if (stored is String && stored.trim().isNotEmpty) {
      _displayName = stored.trim();
    } else {
      _displayName = _defaultName;
    }
  }

  void loadDisplayName() {
    _loadName();
    notifyListeners();
  }

  void setDisplayName(String name) {
    final sanitized = name.trim();
    _displayName = sanitized.isEmpty ? _defaultName : sanitized;
    HiveService.getSettingsBox().put(_storageKey, _displayName);
    notifyListeners();
  }
}
