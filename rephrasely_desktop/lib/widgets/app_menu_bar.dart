import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/app_state_provider.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final appState = context.watch<AppStateProvider>();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            'Rephrasely',
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 32),
          _MenuButton(
            title: 'Dashboard',
            isActive: appState.currentScreen == AppScreen.dashboard,
            onPressed: () {
              appState.navigateToDashboard();
            },
          ),
          const SizedBox(width: 8),
          _SettingsMenuButton(),
          const SizedBox(width: 8),
          _HotkeysMenuButton(),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.title,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadButton(
      onPressed: onPressed,
      decoration: ShadDecoration(
        color: isActive ? theme.colorScheme.accent : Colors.transparent,
      ),
      child: Text(title),
    );
  }
}

class _SettingsMenuButton extends StatefulWidget {
  @override
  State<_SettingsMenuButton> createState() => _SettingsMenuButtonState();
}

class _SettingsMenuButtonState extends State<_SettingsMenuButton> {
  final _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isActive = appState.currentScreen == AppScreen.settings;

    return ShadPopover(
      controller: _popoverController,
      popover:
          (context) => ShadCard(
            width: 220,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PopoverMenuItem(
                  title: 'OpenRouter API Keys',
                  subtitle: 'Configure API access',
                  onTap: () {
                    context.read<AppStateProvider>().navigateToSettingsTab(
                      SettingsTab.openRouterApi,
                    );
                    _popoverController.toggle();
                  },
                ),
                const SizedBox(height: 4),
                _PopoverMenuItem(
                  title: 'App Theme',
                  subtitle: 'Light or dark mode',
                  onTap: () {
                    context.read<AppStateProvider>().navigateToSettingsTab(
                      SettingsTab.appTheme,
                    );
                    _popoverController.toggle();
                  },
                ),
              ],
            ),
          ),
      child: _MenuButton(
        title: 'Settings',
        isActive: isActive,
        onPressed: _popoverController.toggle,
      ),
    );
  }
}

class _HotkeysMenuButton extends StatefulWidget {
  @override
  State<_HotkeysMenuButton> createState() => _HotkeysMenuButtonState();
}

class _HotkeysMenuButtonState extends State<_HotkeysMenuButton> {
  final _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isActive = appState.currentScreen == AppScreen.hotkeys;

    return ShadPopover(
      controller: _popoverController,
      popover:
          (context) => ShadCard(
            width: 220,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PopoverMenuItem(
                  title: 'Keyboard Shortcuts',
                  subtitle: 'View and configure',
                  onTap: () {
                    context.read<AppStateProvider>().navigateToScreen(
                      AppScreen.hotkeys,
                    );
                    _popoverController.toggle();
                  },
                ),
              ],
            ),
          ),
      child: _MenuButton(
        title: 'Hotkeys',
        isActive: isActive,
        onPressed: _popoverController.toggle,
      ),
    );
  }
}

class _PopoverMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PopoverMenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: theme.textTheme.muted.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
