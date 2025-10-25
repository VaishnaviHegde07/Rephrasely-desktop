import 'package:flutter/material.dart';

enum AppScreen { dashboard, settings, hotkeys }

enum SettingsTab { openRouterApi, appTheme, chatPersona }

class AppStateProvider extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.dashboard;
  SettingsTab? _currentSettingsTab;

  AppScreen get currentScreen => _currentScreen;
  SettingsTab? get currentSettingsTab => _currentSettingsTab;

  void navigateToScreen(AppScreen screen, {SettingsTab? settingsTab}) {
    _currentScreen = screen;
    _currentSettingsTab = settingsTab;
    notifyListeners();
  }

  void navigateToSettingsTab(SettingsTab tab) {
    _currentScreen = AppScreen.settings;
    _currentSettingsTab = tab;
    notifyListeners();
  }

  void navigateToDashboard() {
    _currentScreen = AppScreen.dashboard;
    _currentSettingsTab = null;
    notifyListeners();
  }
}
