import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/app_settings.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  AppSettings _settings = AppSettings();

  bool get isDarkMode => _settings.isDarkMode;
  AppThemeMode get themeMode => _settings.themeMode;
  ChatPersonaIcon get chatPersonaIcon => _settings.chatPersonaIcon;
  String? get apiKey => _settings.openRouterApiKey;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await _storageService.loadSettings();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _settings = _settings.copyWith(isDarkMode: isDark);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setChatPersonaIcon(ChatPersonaIcon icon) async {
    _settings = _settings.copyWith(chatPersonaIcon: icon);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> saveApiKey(String apiKey) async {
    _settings = _settings.copyWith(openRouterApiKey: apiKey);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    _settings = _settings.copyWith(openRouterApiKey: '');
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }
}
