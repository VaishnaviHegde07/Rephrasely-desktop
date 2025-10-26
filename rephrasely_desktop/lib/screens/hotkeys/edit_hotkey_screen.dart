import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../models/hotkey.dart';
import '../../models/ai_model.dart';
import '../../models/app_settings.dart';
import '../../providers/hotkey_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';

class EditHotkeyScreen extends StatefulWidget {
  final Hotkey? hotkey;

  const EditHotkeyScreen({super.key, this.hotkey});

  @override
  State<EditHotkeyScreen> createState() => _EditHotkeyScreenState();
}

class _EditHotkeyScreenState extends State<EditHotkeyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _customPromptController;
  final _modelSearchController = TextEditingController();
  final _modelPopoverController = ShadPopoverController();

  String _keyCombo = '';
  final List<String> _pressedKeys = [];
  String _modelSearchQuery = '';
  ModelFilter _modelFilter = ModelFilter.top;
  HotkeyActionType _actionType = HotkeyActionType.rephrase;
  HotkeyStyle _style = HotkeyStyle.professional;
  AIModel? _selectedModel;
  bool _isActive = true;
  bool _showNotification = true;
  bool _saveToHistory = true;
  bool _isListeningForKeys = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotkey?.name ?? '');
    _customPromptController = TextEditingController(
      text: widget.hotkey?.customPrompt ?? '',
    );

    if (widget.hotkey != null) {
      _keyCombo = widget.hotkey!.keyCombo;
      _actionType = widget.hotkey!.actionType;
      _style = widget.hotkey!.style ?? HotkeyStyle.professional;
      _isActive = widget.hotkey!.isActive;
      _showNotification = widget.hotkey!.showNotification;
      _saveToHistory = widget.hotkey!.saveToHistory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customPromptController.dispose();
    _modelSearchController.dispose();
    _modelPopoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dashboardProvider = context.watch<DashboardProvider>();

    // Set default model if not set
    if (_selectedModel == null) {
      if (widget.hotkey != null && dashboardProvider.allModels.isNotEmpty) {
        try {
          _selectedModel = dashboardProvider.allModels.firstWhere(
            (m) => m.id == widget.hotkey!.modelId,
          );
        } catch (e) {
          _selectedModel = dashboardProvider.allModels.first;
        }
      } else if (dashboardProvider.selectedModel != null) {
        _selectedModel = dashboardProvider.selectedModel;
      } else if (dashboardProvider.allModels.isNotEmpty) {
        _selectedModel = dashboardProvider.allModels.first;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.hotkey == null ? 'Add Hotkey' : 'Edit Hotkey',
          style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShadButton(onPressed: _saveHotkey, child: Text('Save')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: theme.textTheme.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Name
                        Text('Name', style: theme.textTheme.small),
                        const SizedBox(height: 8),
                        ShadInput(
                          controller: _nameController,
                          placeholder: Text('e.g., Rephrase Professionally'),
                        ),
                        const SizedBox(height: 24),

                        // Keyboard Shortcut
                        Text('Keyboard Shortcut', style: theme.textTheme.small),
                        const SizedBox(height: 8),
                        _buildKeyboardShortcutInput(theme),
                        const SizedBox(height: 8),
                        Text(
                          'Click the button and press your desired key combination',
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Configuration
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Action Configuration',
                          style: theme.textTheme.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Type
                        Text('Action Type', style: theme.textTheme.small),
                        const SizedBox(height: 8),
                        _buildActionTypeSelector(theme),
                        const SizedBox(height: 24),

                        // Style (only show if NOT custom action)
                        if (_actionType != HotkeyActionType.custom) ...[
                          Text('Style', style: theme.textTheme.small),
                          const SizedBox(height: 8),
                          _buildStyleSelector(theme),
                          const SizedBox(height: 24),
                        ],

                        // Custom Prompt (only show if custom action)
                        if (_actionType == HotkeyActionType.custom) ...[
                          Text('Custom Prompt *', style: theme.textTheme.small),
                          const SizedBox(height: 8),
                          ShadInput(
                            controller: _customPromptController,
                            placeholder: const Text(
                              'Enter your complete prompt instruction...',
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Example: "Rewrite the following text in a {style} tone: {text}"',
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // AI Model
                        Text('AI Model', style: theme.textTheme.small),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Model Filter: Top | Fast | All
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.muted.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildFilterButton(
                                    theme,
                                    'Top',
                                    Icons.star_rounded,
                                    ModelFilter.top,
                                  ),
                                  _buildFilterButton(
                                    theme,
                                    'Fast',
                                    Icons.flash_on_rounded,
                                    ModelFilter.fast,
                                  ),
                                  _buildFilterButton(
                                    theme,
                                    'All',
                                    Icons.list_rounded,
                                    ModelFilter.all,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Model Selector
                            _buildModelSelector(theme, dashboardProvider),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Behavior Settings
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Behavior Settings',
                          style: theme.textTheme.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Active Toggle
                        _buildSwitchRow(
                          theme,
                          'Enable Hotkey',
                          'Activate this keyboard shortcut',
                          _isActive,
                          (value) => setState(() => _isActive = value),
                        ),
                        const SizedBox(height: 16),

                        // Show Notification
                        _buildSwitchRow(
                          theme,
                          'Show Notification',
                          'Display notification during text processing',
                          _showNotification,
                          (value) => setState(() => _showNotification = value),
                        ),
                        const SizedBox(height: 16),

                        // Save to History
                        _buildSwitchRow(
                          theme,
                          'Save to History',
                          'Save transformations to history',
                          _saveToHistory,
                          (value) => setState(() => _saveToHistory = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardShortcutInput(ShadThemeData theme) {
    return GestureDetector(
      onTap: _startListeningForKeys,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              _isListeningForKeys
                  ? theme.colorScheme.accent
                  : theme.colorScheme.muted.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _isListeningForKeys
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
            width: _isListeningForKeys ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isListeningForKeys ? Icons.keyboard : Icons.keyboard_outlined,
              color:
                  _isListeningForKeys
                      ? theme.colorScheme.primary
                      : theme.colorScheme.foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _keyCombo.isEmpty
                    ? (_isListeningForKeys
                        ? 'Press keys now...'
                        : 'Click to set shortcut')
                    : _keyCombo.toUpperCase(),
                style: theme.textTheme.small.copyWith(
                  color:
                      _isListeningForKeys
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                  fontWeight:
                      _keyCombo.isEmpty ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (_keyCombo.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _keyCombo = ''),
              ),
          ],
        ),
      ),
    );
  }

  void _startListeningForKeys() {
    setState(() {
      _isListeningForKeys = true;
      _pressedKeys.clear();
    });

    // Use StatefulBuilder to update the dialog in real-time
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return KeyboardListener(
                focusNode: FocusNode()..requestFocus(),
                autofocus: true,
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    final key = _getKeyLabel(event.logicalKey);
                    if (!_pressedKeys.contains(key)) {
                      setDialogState(() {
                        _pressedKeys.add(key);
                      });
                    }
                  } else if (event is KeyUpEvent) {
                    if (_pressedKeys.isNotEmpty) {
                      final newCombo = _pressedKeys.join('+');

                      // Check if this combination is already in use
                      final provider = context.read<HotkeyProvider>();
                      final isDuplicate = provider.hotkeys.any(
                        (h) =>
                            h.keyCombo.toLowerCase() ==
                                newCombo.toLowerCase() &&
                            h.id != widget.hotkey?.id,
                      );

                      if (isDuplicate) {
                        // Show error and reset
                        setDialogState(() {
                          _pressedKeys.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Shortcut "$newCombo" is already in use. Please choose a different combination.',
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        setState(() {
                          _keyCombo = newCombo;
                          _isListeningForKeys = false;
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  }
                },
                child: AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.keyboard, size: 24),
                      const SizedBox(width: 12),
                      Text('Record Shortcut'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Press your desired key combination',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Release keys when done',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _pressedKeys.isEmpty
                                    ? Colors.grey[300]!
                                    : Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _pressedKeys.isEmpty
                              ? 'Waiting...'
                              : _pressedKeys
                                  .map((k) => k.toUpperCase())
                                  .join(' + '),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                _pressedKeys.isEmpty
                                    ? Colors.grey[400]
                                    : Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_pressedKeys.isNotEmpty)
                        Text(
                          'Release keys to confirm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => _isListeningForKeys = false);
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return 'cmd';
    } else if (key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return 'shift';
    } else if (key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return 'ctrl';
    } else if (key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return 'alt';
    } else {
      return key.keyLabel.toLowerCase();
    }
  }

  Widget _buildActionTypeSelector(ShadThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          HotkeyActionType.values.map((type) {
            final isSelected = _actionType == type;
            return GestureDetector(
              onTap: () => setState(() => _actionType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.border,
                  ),
                ),
                child: Text(
                  type.displayName,
                  style: theme.textTheme.small.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.primaryForeground
                            : theme.colorScheme.foreground,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStyleSelector(ShadThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          HotkeyStyle.values.map((style) {
            final isSelected = _style == style;
            return GestureDetector(
              onTap: () => setState(() => _style = style),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.accent
                          : theme.colorScheme.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.border,
                  ),
                ),
                child: Text(
                  style.displayName,
                  style: theme.textTheme.small.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.accentForeground
                            : theme.colorScheme.foreground,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildModelSelector(
    ShadThemeData theme,
    DashboardProvider dashboardProvider,
  ) {
    final themeProvider = context.read<ThemeProvider>();
    final personaIcon = _getPersonaIcon(themeProvider.chatPersonaIcon);

    return ShadPopover(
      controller: _modelPopoverController,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: ShadButton(
          size: ShadButtonSize.sm,
          onPressed: _modelPopoverController.toggle,
          decoration: ShadDecoration(color: theme.colorScheme.secondary),
          icon: Icon(personaIcon, size: 16),
          child: Flexible(
            child: Text(
              _selectedModel?.name ?? 'Select Model',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
      popover: (context) {
        // Get the provider from context to ensure we have the latest state
        final provider = context.read<DashboardProvider>();

        // Get available models based on filter
        final availableModels = () {
          switch (_modelFilter) {
            case ModelFilter.top:
              return provider.topModels;
            case ModelFilter.fast:
              return provider.fastModels;
            case ModelFilter.all:
              return provider.allModels;
          }
        }();

        // Filter models based on search query
        final filteredModels =
            _modelSearchQuery.isEmpty
                ? availableModels
                : availableModels.where((model) {
                  return model.name.toLowerCase().contains(
                        _modelSearchQuery.toLowerCase(),
                      ) ||
                      model.id.toLowerCase().contains(
                        _modelSearchQuery.toLowerCase(),
                      );
                }).toList();

        return ShadCard(
          width: 320,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search bar (show when "Fast" or "All" models is selected)
              if (_modelFilter == ModelFilter.fast ||
                  _modelFilter == ModelFilter.all) ...[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ShadInput(
                    controller: _modelSearchController,
                    placeholder: const Text('Search models...'),
                    onChanged: (value) {
                      setState(() {
                        _modelSearchQuery = value;
                      });
                    },
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search, size: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredModels.length} models',
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                      ),
                      if (_modelSearchQuery.isNotEmpty) ...[
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _modelSearchQuery = '';
                              _modelSearchController.clear();
                            });
                          },
                          child: Text(
                            'Clear',
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.border),
              ],
              // Model list
              if (filteredModels.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        availableModels.isEmpty
                            ? 'No models loaded'
                            : 'No models found',
                        style: theme.textTheme.small,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        availableModels.isEmpty
                            ? 'Please set up your API key first'
                            : 'Try a different search term',
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredModels.length,
                    itemBuilder: (context, index) {
                      final model = filteredModels[index];
                      final isSelected = _selectedModel?.id == model.id;

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedModel = model);
                          _modelPopoverController.toggle();
                          // Clear search when selecting
                          setState(() {
                            _modelSearchQuery = '';
                            _modelSearchController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          color:
                              isSelected
                                  ? theme.colorScheme.accent
                                  : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.name,
                                      style: theme.textTheme.small.copyWith(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      model.id,
                                      style: theme.textTheme.muted.copyWith(
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow(
    ShadThemeData theme,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        ShadSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  void _saveHotkey() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        _showError('Please enter a name for the hotkey');
        return;
      }

      if (_keyCombo.isEmpty) {
        _showError('Please set a keyboard shortcut');
        return;
      }

      if (_selectedModel == null) {
        _showError('Please select an AI model');
        return;
      }

      // Validate custom prompt is required for custom actions
      if (_actionType == HotkeyActionType.custom &&
          _customPromptController.text.trim().isEmpty) {
        _showError('Please enter a custom prompt for custom actions');
        return;
      }

      final hotkey = Hotkey(
        id:
            widget.hotkey?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        keyCombo: _keyCombo,
        modelId: _selectedModel!.id,
        modelName: _selectedModel!.name,
        actionType: _actionType,
        // Style is null for custom actions
        style: _actionType == HotkeyActionType.custom ? null : _style,
        customPrompt:
            _customPromptController.text.trim().isEmpty
                ? null
                : _customPromptController.text.trim(),
        isActive: _isActive,
        showNotification: _showNotification,
        saveToHistory: _saveToHistory,
        lastUsed: widget.hotkey?.lastUsed,
        createdAt: widget.hotkey?.createdAt,
      );

      final hotkeyProvider = context.read<HotkeyProvider>();
      if (widget.hotkey == null) {
        hotkeyProvider.addHotkey(hotkey);
      } else {
        hotkeyProvider.updateHotkey(hotkey);
      }

      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildFilterButton(
    ShadThemeData theme,
    String label,
    IconData icon,
    ModelFilter filter,
  ) {
    final isSelected = filter == _modelFilter;
    return InkWell(
      onTap: () {
        setState(() {
          _modelFilter = filter;
          _modelSearchQuery = '';
          _modelSearchController.clear();
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isSelected
                      ? theme.colorScheme.primaryForeground
                      : theme.colorScheme.foreground.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.foreground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPersonaIcon(ChatPersonaIcon icon) {
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
}
