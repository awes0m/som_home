import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_service.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load initial value (could be async, but Hive is synchronous here)
    final box = HiveService.getSettingsBox();
    final theme = box.get('theme_mode', defaultValue: 'system');
    return ThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => ThemeMode.system,
    );
  }

  void loadThemeMode() {
    // Reload from storage - in Riverpod, we can refetch or update state
    final box = HiveService.getSettingsBox();
    final theme = box.get('theme_mode', defaultValue: 'system');
    final newMode = ThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => ThemeMode.system,
    );
    state = newMode;
  }

  void setThemeMode(ThemeMode mode) {
    HiveService.getSettingsBox().put('theme_mode', mode.name);
    state = mode;
  }
}

// Provider declaration
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
