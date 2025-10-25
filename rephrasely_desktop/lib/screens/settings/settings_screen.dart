import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import 'openrouter_api_screen.dart';
import 'app_theme_screen.dart';
import 'chat_persona_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    switch (appState.currentSettingsTab) {
      case SettingsTab.openRouterApi:
        return const OpenRouterApiScreen();
      case SettingsTab.appTheme:
        return const AppThemeScreen();
      case SettingsTab.chatPersona:
        return const ChatPersonaScreen();
      case null:
        return const OpenRouterApiScreen(); // Default to API screen
    }
  }
}
