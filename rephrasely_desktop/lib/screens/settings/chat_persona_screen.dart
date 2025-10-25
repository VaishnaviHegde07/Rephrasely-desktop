import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_settings.dart';

class ChatPersonaScreen extends StatefulWidget {
  const ChatPersonaScreen({super.key});

  @override
  State<ChatPersonaScreen> createState() => _ChatPersonaScreenState();
}

class _ChatPersonaScreenState extends State<ChatPersonaScreen> {
  bool _showAllIcons = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatPersonaIcon> get _topIcons => [
    ChatPersonaIcon.robot,
    ChatPersonaIcon.brain,
    ChatPersonaIcon.sparkles,
    ChatPersonaIcon.star,
    ChatPersonaIcon.rocket,
  ];

  List<ChatPersonaIcon> get _filteredIcons {
    final icons = _showAllIcons ? ChatPersonaIcon.values : _topIcons;

    if (_searchQuery.isEmpty) {
      return icons;
    }

    return icons.where((icon) {
      final label = _getIconLabel(icon).toLowerCase();
      return label.contains(_searchQuery.toLowerCase());
    }).toList();
  }

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
                Text('Chat Persona', style: theme.textTheme.h1),
                const SizedBox(height: 8),
                Text(
                  'Customize the AI assistant\'s appearance in chat',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 32),

                // Persona Icon Selection
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Assistant Icon',
                                style: theme.textTheme.large.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose an icon that represents your AI assistant',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          // Toggle: Top vs All Icons
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () {
                              setState(() {
                                _showAllIcons = !_showAllIcons;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            decoration: ShadDecoration(
                              color: theme.colorScheme.muted,
                            ),
                            icon: Icon(
                              _showAllIcons
                                  ? Icons.list_rounded
                                  : Icons.star_rounded,
                              size: 14,
                            ),
                            child: Text(
                              _showAllIcons ? 'All' : 'Top',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search bar (only show when "All" icons is selected)
                      if (_showAllIcons) ...[
                        ShadInput(
                          controller: _searchController,
                          placeholder: const Text('Search icons...'),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.search, size: 16),
                          ),
                          suffix:
                              _searchQuery.isNotEmpty
                                  ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.close, size: 16),
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_filteredIcons.length} icons',
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Icon Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            _filteredIcons.map((icon) {
                              return _PersonaIconCard(
                                icon: icon,
                                iconData: _getIconData(icon),
                                label: _getIconLabel(icon),
                                color: _getIconColor(icon),
                                isSelected:
                                    themeProvider.chatPersonaIcon == icon,
                                onTap:
                                    () =>
                                        themeProvider.setChatPersonaIcon(icon),
                                theme: theme,
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

                      // Preview Message
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getIconColor(
                                themeProvider.chatPersonaIcon,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconData(themeProvider.chatPersonaIcon),
                              size: 20,
                              color: _getIconColor(
                                themeProvider.chatPersonaIcon,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.muted.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Assistant',
                                    style: theme.textTheme.small.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This is how the AI assistant will appear in your chats with the selected icon.',
                                    style: theme.textTheme.small,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  IconData _getIconData(ChatPersonaIcon icon) {
    switch (icon) {
      case ChatPersonaIcon.robot:
        return Icons.smart_toy_rounded;
      case ChatPersonaIcon.brain:
        return Icons.psychology_rounded;
      case ChatPersonaIcon.sparkles:
        return Icons.auto_awesome_rounded;
      case ChatPersonaIcon.star:
        return Icons.star_rounded;
      case ChatPersonaIcon.rocket:
        return Icons.rocket_launch_rounded;
      case ChatPersonaIcon.lightbulb:
        return Icons.lightbulb_rounded;
      case ChatPersonaIcon.graduation:
        return Icons.school_rounded;
      case ChatPersonaIcon.heart:
        return Icons.favorite_rounded;
      case ChatPersonaIcon.fire:
        return Icons.local_fire_department_rounded;
      case ChatPersonaIcon.diamond:
        return Icons.diamond_rounded;
    }
  }

  String _getIconLabel(ChatPersonaIcon icon) {
    switch (icon) {
      case ChatPersonaIcon.robot:
        return 'Robot';
      case ChatPersonaIcon.brain:
        return 'Brain';
      case ChatPersonaIcon.sparkles:
        return 'Sparkles';
      case ChatPersonaIcon.star:
        return 'Star';
      case ChatPersonaIcon.rocket:
        return 'Rocket';
      case ChatPersonaIcon.lightbulb:
        return 'Lightbulb';
      case ChatPersonaIcon.graduation:
        return 'Scholar';
      case ChatPersonaIcon.heart:
        return 'Heart';
      case ChatPersonaIcon.fire:
        return 'Fire';
      case ChatPersonaIcon.diamond:
        return 'Diamond';
    }
  }

  Color _getIconColor(ChatPersonaIcon icon) {
    switch (icon) {
      case ChatPersonaIcon.robot:
        return const Color(0xFF3B82F6);
      case ChatPersonaIcon.brain:
        return const Color(0xFF8B5CF6);
      case ChatPersonaIcon.sparkles:
        return const Color(0xFFF59E0B);
      case ChatPersonaIcon.star:
        return const Color(0xFFFBBF24);
      case ChatPersonaIcon.rocket:
        return const Color(0xFFEF4444);
      case ChatPersonaIcon.lightbulb:
        return const Color(0xFFF59E0B);
      case ChatPersonaIcon.graduation:
        return const Color(0xFF10B981);
      case ChatPersonaIcon.heart:
        return const Color(0xFFEC4899);
      case ChatPersonaIcon.fire:
        return const Color(0xFFDC2626);
      case ChatPersonaIcon.diamond:
        return const Color(0xFF06B6D4);
    }
  }
}

class _PersonaIconCard extends StatelessWidget {
  final ChatPersonaIcon icon;
  final IconData iconData;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final ShadThemeData theme;

  const _PersonaIconCard({
    required this.icon,
    required this.iconData,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
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
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.small.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
