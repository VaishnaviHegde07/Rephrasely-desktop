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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 12),

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
              const SizedBox(width: 12),

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
              const SizedBox(width: 12),

              // API Usage (with limit if available)
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'API Usage',
                  value: _getCreditDisplay(dashboard.creditInfo),
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

  String _getCreditDisplay(Map<String, dynamic>? creditInfo) {
    if (creditInfo == null) return 'N/A';

    // OpenRouter API returns usage and optional limit
    final usage = (creditInfo['usage'] ?? 0.0) as num;
    final limit = creditInfo['limit']; // Can be null

    // If we have a limit, show "usage / limit"
    if (limit != null && limit is num && limit > 0) {
      return '\$${usage.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}';
    }

    // No limit set - just show usage only
    return '\$${usage.toStringAsFixed(2)}';
  }
}

class _StatCard extends StatefulWidget {
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
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _isHovered
                          ? widget.color.withOpacity(0.3)
                          : widget.theme.colorScheme.border,
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, size: 20, color: widget.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.value,
                          style: widget.theme.textTheme.p.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: widget.theme.colorScheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.label,
                          style: widget.theme.textTheme.muted.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
