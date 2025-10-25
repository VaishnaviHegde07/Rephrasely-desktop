import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/hotkey_provider.dart';
import '../providers/history_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/hotkey_service.dart';
import '../services/text_processing_service.dart';
import '../services/hotkey_coordinator_service.dart';
import '../widgets/sidebar_menu.dart';
import 'dashboard/dashboard_screen.dart';
import 'settings/settings_screen.dart' as settings;
import 'hotkeys/hotkeys_screen.dart';
import 'history/history_screen.dart';

class MainScreen extends StatefulWidget {
  final HotkeyService hotkeyService;
  final TextProcessingService textProcessingService;

  const MainScreen({
    super.key,
    required this.hotkeyService,
    required this.textProcessingService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  HotkeyCoordinatorService? _coordinator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize coordinator once
    if (_coordinator == null) {
      final hotkeyProvider = context.read<HotkeyProvider>();
      final historyProvider = context.read<HistoryProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      _coordinator = HotkeyCoordinatorService(
        hotkeyService: widget.hotkeyService,
        textProcessingService: widget.textProcessingService,
        hotkeyProvider: hotkeyProvider,
        historyProvider: historyProvider,
        dashboardProvider: dashboardProvider,
      );

      print('🚀 MainScreen: Hotkey coordinator initialized');
    }
  }

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
                  case AppScreen.history:
                    return const HistoryScreen();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
