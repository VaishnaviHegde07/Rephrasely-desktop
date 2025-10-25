import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/hotkey_provider.dart';
import '../../models/hotkey.dart';
import 'edit_hotkey_screen.dart';

class HotkeysScreen extends StatelessWidget {
  const HotkeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hotkeyProvider = context.watch<HotkeyProvider>();

    return Container(
      color: theme.colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hotkeys',
                        style: theme.textTheme.h2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage keyboard shortcuts for quick text actions',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                ShadButton(
                  onPressed: () => _showEditScreen(context, null),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      const SizedBox(width: 8),
                      Text('Add Hotkey'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                hotkeyProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hotkeyProvider.hotkeys.isEmpty
                    ? _buildEmptyState(context, theme)
                    : _buildHotkeysList(context, theme, hotkeyProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ShadThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_outlined,
            size: 80,
            color: theme.colorScheme.muted,
          ),
          const SizedBox(height: 24),
          Text('No hotkeys yet', style: theme.textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Create your first hotkey to get started',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: () => _showEditScreen(context, null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                const SizedBox(width: 8),
                Text('Add Hotkey'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotkeysList(
    BuildContext context,
    ShadThemeData theme,
    HotkeyProvider provider,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ShadCard(
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.border),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Active',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Shortcut',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Model',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Actions',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...provider.hotkeys.asMap().entries.map((entry) {
                final index = entry.key;
                final hotkey = entry.value;
                final isLast = index == provider.hotkeys.length - 1;

                return _HotkeyRow(
                  hotkey: hotkey,
                  isLast: isLast,
                  onToggle: () => provider.toggleHotkey(hotkey.id),
                  onEdit: () => _showEditScreen(context, hotkey),
                  onDelete: () => _confirmDelete(context, provider, hotkey),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditScreen(BuildContext context, Hotkey? hotkey) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditHotkeyScreen(hotkey: hotkey)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HotkeyProvider provider,
    Hotkey hotkey,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Hotkey'),
            content: Text(
              'Are you sure you want to delete "${hotkey.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.deleteHotkey(hotkey.id);
    }
  }
}

class _HotkeyRow extends StatelessWidget {
  final Hotkey hotkey;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HotkeyRow({
    required this.hotkey,
    required this.isLast,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          // Active Toggle
          SizedBox(
            width: 60,
            child: ShadSwitch(
              value: hotkey.isActive,
              onChanged: (_) => onToggle(),
            ),
          ),

          // Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotkey.name,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hotkey.style != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hotkey.style!.displayName,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          // Shortcut
          Expanded(flex: 2, child: _buildKeyCombo(context, hotkey.keyCombo)),

          // Action
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hotkey.actionType.displayName,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),

          // Model
          Expanded(
            flex: 2,
            child: Text(
              _truncateModelName(hotkey.modelName),
              style: theme.textTheme.muted.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action Buttons
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyCombo(BuildContext context, String keyCombo) {
    final theme = ShadTheme.of(context);
    final keys = keyCombo.split('+');

    return Wrap(
      spacing: 4,
      children:
          keys.map((key) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: Text(
                key.toUpperCase(),
                style: theme.textTheme.muted.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
    );
  }

  String _truncateModelName(String name) {
    if (name.length > 20) {
      return '${name.substring(0, 20)}...';
    }
    return name;
  }
}
