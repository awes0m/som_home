import 'package:flutter/material.dart';
import 'storage/hive_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final box = HiveService.getSettingsBox();
    final theme = box.get('theme_mode', defaultValue: 'system');
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => ThemeMode.system,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    HiveService.getSettingsBox().put('theme_mode', mode.name);
    notifyListeners();
  }
}