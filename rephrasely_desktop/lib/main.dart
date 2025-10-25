import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'providers/theme_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/hotkey_provider.dart';
import 'providers/history_provider.dart';
import 'services/storage_service.dart';
import 'services/hotkey_service.dart';
import 'services/openrouter_service.dart';
import 'services/text_processing_service.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'config/theme_config.dart';

void main() async {
  // Ensure Flutter binding is initialized before setting up services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services after binding is ready
  final storageService = StorageService();
  final hotkeyService = HotkeyService();
  final openRouterService = OpenRouterService();
  final textProcessingService = TextProcessingService(openRouterService);

  // Load API key at startup
  try {
    final settings = await storageService.loadSettings();
    if (settings.openRouterApiKey != null &&
        settings.openRouterApiKey!.isNotEmpty) {
      openRouterService.setApiKey(settings.openRouterApiKey!);
      print('✅ Main: API key loaded from storage');
    } else {
      print('⚠️  Main: No API key found in storage');
    }
  } catch (e) {
    print('❌ Main: Error loading API key: $e');
  }

  runApp(
    MyApp(
      storageService: storageService,
      hotkeyService: hotkeyService,
      openRouterService: openRouterService,
      textProcessingService: textProcessingService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final HotkeyService hotkeyService;
  final OpenRouterService openRouterService;
  final TextProcessingService textProcessingService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.hotkeyService,
    required this.openRouterService,
    required this.textProcessingService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(
          create: (_) => HotkeyProvider(storageService, hotkeyService),
        ),
        ChangeNotifierProvider(create: (_) => HistoryProvider(hotkeyService)),
        // Provide services for easy access
        Provider.value(value: hotkeyService),
        Provider.value(value: openRouterService),
        Provider.value(value: textProcessingService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final theme = ThemeConfig.getTheme(themeProvider.themeMode);

          return ShadApp(
            title: 'Rephrasely Desktop',
            theme: theme,
            navigatorKey: NotificationService.navigatorKey,
            home: MainScreen(
              hotkeyService: hotkeyService,
              textProcessingService: textProcessingService,
            ),
          );
        },
      ),
    );
  }
}
