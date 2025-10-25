import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_settings.dart';
import '../../config/theme_config.dart';

class AppThemeScreen extends StatelessWidget {
  const AppThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: theme.textTheme.h1),
                const SizedBox(height: 8),
                Text(
                  'Customize the appearance of your application',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 32),

                // Theme Selection Card
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a theme that suits your style',
                        style: theme.textTheme.muted.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Theme Grid
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children:
                            AppThemeMode.values.map((mode) {
                              return SizedBox(
                                width: 300,
                                child: _ThemeCard(
                                  mode: mode,
                                  title: ThemeConfig.getThemeDisplayName(mode),
                                  description: ThemeConfig.getThemeDescription(
                                    mode,
                                  ),
                                  icon: _getThemeIcon(mode),
                                  color: _getThemeColor(mode),
                                  isSelected: themeProvider.themeMode == mode,
                                  onTap: () => themeProvider.setThemeMode(mode),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Preview Card
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sample Heading', style: theme.textTheme.h3),
                            const SizedBox(height: 8),
                            Text(
                              'This is how your text will look with the current theme.',
                              style: theme.textTheme.small,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ShadButton(
                                  onPressed: () {},
                                  child: const Text('Primary Button'),
                                ),
                                const SizedBox(width: 8),
                                ShadButton(
                                  onPressed: () {},
                                  decoration: ShadDecoration(
                                    color: theme.colorScheme.secondary,
                                  ),
                                  child: const Text('Secondary Button'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.neutral:
        return Icons.contrast_rounded;
      case AppThemeMode.ocean:
        return Icons.water_rounded;
      case AppThemeMode.sunset:
        return Icons.wb_sunny_rounded;
      case AppThemeMode.forest:
        return Icons.forest_rounded;
    }
  }

  Color _getThemeColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFF3B82F6);
      case AppThemeMode.dark:
        return const Color(0xFF1F2937);
      case AppThemeMode.neutral:
        return const Color(0xFF64748B);
      case AppThemeMode.ocean:
        return const Color(0xFF0284C7);
      case AppThemeMode.sunset:
        return const Color(0xFFEA580C);
      case AppThemeMode.forest:
        return const Color(0xFF16A34A);
    }
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.accent : theme.colorScheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Color preview circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
