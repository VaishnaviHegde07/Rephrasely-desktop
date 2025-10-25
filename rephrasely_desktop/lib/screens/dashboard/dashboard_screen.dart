import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/dashboard_chat_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize dashboard with API key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = context.read<ThemeProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      if (themeProvider.apiKey != null && themeProvider.apiKey!.isNotEmpty) {
        dashboardProvider.setApiKey(themeProvider.apiKey!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dashboard = context.watch<DashboardProvider>();

    return Column(
      children: [
        // Horizontal Stats Board at Top
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withOpacity(0.3),
            border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Row(
            children: [
              // Hotkeys Registered
              Expanded(
                child: _StatCard(
                  icon: Icons.keyboard_rounded,
                  label: 'Hotkeys Registered',
                  value: dashboard.stats.hotkeysRegistered.toString(),
                  color: const Color(0xFFF59E0B),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),

              // Tokens Used
              Expanded(
                child: _StatCard(
                  icon: Icons.token_rounded,
                  label: 'Tokens Used',
                  value: _formatNumber(dashboard.stats.tokensUsed),
                  color: const Color(0xFF8B5CF6),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),

              // Total Messages
              Expanded(
                child: _StatCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Total Messages',
                  value: dashboard.stats.messagesCount.toString(),
                  color: const Color(0xFF3B82F6),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),

              // Models with Hotkeys
              Expanded(
                child: _StatCard(
                  icon: Icons.smart_toy_rounded,
                  label: 'Models with Hotkeys',
                  value: dashboard.hotkeys.length.toString(),
                  color: const Color(0xFF10B981),
                  theme: theme,
                ),
              ),
            ],
          ),
        ),

        // Chat Area
        const Expanded(child: DashboardChatWidget()),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ShadThemeData theme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
