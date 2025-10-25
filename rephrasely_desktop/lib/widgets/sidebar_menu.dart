import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final appState = context.watch<AppStateProvider>();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rephrasely',
                  style: theme.textTheme.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desktop App',
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: appState.currentScreen == AppScreen.dashboard,
                  onTap: () => appState.navigateToDashboard(),
                ),
                const SizedBox(height: 4),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Text(
                    'Settings',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.key_rounded,
                  label: 'API Keys',
                  isActive:
                      appState.currentScreen == AppScreen.settings &&
                      appState.currentSettingsTab == SettingsTab.openRouterApi,
                  onTap:
                      () => appState.navigateToSettingsTab(
                        SettingsTab.openRouterApi,
                      ),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.palette_rounded,
                  label: 'Appearance',
                  isActive:
                      appState.currentScreen == AppScreen.settings &&
                      appState.currentSettingsTab == SettingsTab.appTheme,
                  onTap:
                      () =>
                          appState.navigateToSettingsTab(SettingsTab.appTheme),
                ),

                // Hotkeys Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Text(
                    'Tools',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.keyboard_rounded,
                  label: 'Hotkeys',
                  isActive: appState.currentScreen == AppScreen.hotkeys,
                  onTap: () => appState.navigateToScreen(AppScreen.hotkeys),
                ),
                const SizedBox(height: 4),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isActive: appState.currentScreen == AppScreen.history,
                  onTap: () => appState.navigateToScreen(AppScreen.history),
                ),
              ],
            ),
          ),

          // Donation Section - Subtle
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => _launchDonationUrl(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.colorScheme.border.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Support',
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchDonationUrl() async {
    final Uri url = Uri.parse('https://github.com/sponsors/your-username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.foreground,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.small.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color:
                    isActive
                        ? theme.colorScheme.foreground
                        : theme.colorScheme.foreground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
