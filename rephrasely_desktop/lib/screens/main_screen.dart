import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/sidebar_menu.dart';
import 'dashboard/dashboard_screen.dart';
import 'settings/settings_screen.dart' as settings;
import 'hotkeys/hotkeys_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          const SidebarMenu(),

          // Main Content Area
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                switch (appState.currentScreen) {
                  case AppScreen.dashboard:
                    return const DashboardScreen();
                  case AppScreen.settings:
                    return const settings.SettingsScreen();
                  case AppScreen.hotkeys:
                    return const HotkeysScreen();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
