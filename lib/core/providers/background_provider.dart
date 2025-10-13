import 'package:flutter/material.dart';
import '../storage/hive_service.dart';

class BackgroundProvider with ChangeNotifier {
  String? _backgroundUrl;
  String? _backgroundType = 'default';

  BackgroundProvider() {
    _loadBackground();
  }

  String? get backgroundUrl => _backgroundUrl;
  String? get backgroundType => _backgroundType;

  void _loadBackground() {
    final box = HiveService.getSettingsBox();
    _backgroundUrl = box.get('background_url');
    _backgroundType = box.get('background_type', defaultValue: 'default');
  }

  void loadBackground() {
    _loadBackground();
    notifyListeners();
  }

  void setBackground(String? url, String type) {
    _backgroundUrl = url;
    _backgroundType = type;
    HiveService.getSettingsBox().put('background_url', url);
    HiveService.getSettingsBox().put('background_type', type);
    notifyListeners();
  }

  void clearBackground() {
    _backgroundUrl = null;
    _backgroundType = 'default';
    HiveService.getSettingsBox().delete('background_url');
    HiveService.getSettingsBox().put('background_type', 'default');
    notifyListeners();
  }
}
