import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/history_provider.dart';
import '../../models/transformation_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transformation History', style: theme.textTheme.h2),
                    const SizedBox(height: 8),
                    Text(
                      'View all your text transformations',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Search
                    SizedBox(
                      width: 300,
                      child: ShadInput(
                        controller: _searchController,
                        placeholder: const Text('Search history...'),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(Icons.search, size: 16),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Clear All Button
                    Consumer<HistoryProvider>(
                      builder: (context, provider, _) {
                        if (provider.isEmpty) return const SizedBox.shrink();
                        return ShadButton(
                          onPressed: () => _showClearConfirmation(context),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          child: const Text('Clear All'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // History Content
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(provider.error!, style: theme.textTheme.large),
                          const SizedBox(height: 16),
                          ShadButton(
                            onPressed: () => provider.reloadHistory(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final history =
                      _searchQuery.isEmpty
                          ? provider.history
                          : provider.searchHistory(_searchQuery);

                  if (history.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  // Group by date
                  final grouped = <String, List<TransformationHistory>>{};
                  for (final entry in history) {
                    final dateKey = entry.dateGroupKey;
                    if (!grouped.containsKey(dateKey)) {
                      grouped[dateKey] = [];
                    }
                    grouped[dateKey]!.add(entry);
                  }

                  final dateKeys = grouped.keys.toList();
                  _sortDateKeys(dateKeys);

                  return ShadCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted.withOpacity(0.3),
                            border: Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.border,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Time',
                                  style: theme.textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  'Hotkey Profile',
                                  style: theme.textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Transformation',
                                  style: theme.textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'Actions',
                                  style: theme.textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Body
                        Expanded(
                          child: ListView.builder(
                            itemCount: dateKeys.length,
                            itemBuilder: (context, index) {
                              final dateKey = dateKeys[index];
                              final entries = grouped[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Section Header
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    color: theme.colorScheme.muted.withOpacity(
                                      0.1,
                                    ),
                                    child: Text(
                                      dateKey,
                                      style: theme.textTheme.small.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                                  // Entries for this date
                                  ...entries.map(
                                    (entry) => _buildHistoryCard(
                                      context,
                                      theme,
                                      entry,
                                      provider,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.mutedForeground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No transformations yet'
                : 'No results found',
            style: theme.textTheme.h3,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Use hotkeys to transform text and see history here'
                : 'Try a different search query',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ShadThemeData theme,
    TransformationHistory entry,
    HistoryProvider provider,
  ) {
    return InkWell(
      onTap: () => _showDetailDialog(context, theme, entry),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Time
            SizedBox(
              width: 60,
              child: Text(
                entry.timeOnly,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Hotkey Profile
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.hotkeyName,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.actionType,
                    style: theme.textTheme.small.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Text Preview (Original → Transformed)
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.originalText,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: theme.colorScheme.mutedForeground.withOpacity(0.5),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      entry.transformedText,
                      style: theme.textTheme.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Actions
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      size: 16,
                      color: theme.colorScheme.foreground.withOpacity(0.7),
                    ),
                    onPressed: () => _copyToClipboard(entry.transformedText),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    tooltip: 'Copy transformed text',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: theme.colorScheme.foreground.withOpacity(0.7),
                    ),
                    onPressed: () => _deleteEntry(context, entry, provider),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    tooltip: 'Delete entry',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    ShadThemeData theme,
    TransformationHistory entry,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.actionType, style: theme.textTheme.h3),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.formattedDate} at ${entry.timeOnly}',
                              style: theme.textTheme.muted,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Original Text
                  Text(
                    'Original',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    child: SelectableText(
                      entry.originalText,
                      style: theme.textTheme.p,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transformed Text
                  Text(
                    'Transformed',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: SelectableText(
                      entry.transformedText,
                      style: theme.textTheme.p,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Model Info
                  Row(
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 14,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.modelName,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton(
                        onPressed: () {
                          _copyToClipboard(entry.transformedText);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.content_copy, size: 16),
                        child: const Text('Copy Transformed Text'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _sortDateKeys(List<String> keys) {
    keys.sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;

      try {
        final dateA = DateTime.parse(a);
        final dateB = DateTime.parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteEntry(
    BuildContext context,
    TransformationHistory entry,
    HistoryProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteEntry(entry.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All History'),
            content: const Text(
              'Are you sure you want to clear all history? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<HistoryProvider>().clearHistory();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }
}
