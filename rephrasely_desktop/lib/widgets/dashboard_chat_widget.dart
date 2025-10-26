import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/dashboard_provider.dart';
import '../providers/theme_provider.dart';
import '../models/chat_session.dart';
import '../models/app_settings.dart';

class _SendMessageIntent extends Intent {
  const _SendMessageIntent();
}

class DashboardChatWidget extends StatefulWidget {
  const DashboardChatWidget({super.key});

  @override
  State<DashboardChatWidget> createState() => _DashboardChatWidgetState();
}

class _DashboardChatWidgetState extends State<DashboardChatWidget> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _modelPopoverController = ShadPopoverController();
  final _modelSearchController = TextEditingController();
  String _modelSearchQuery = '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _modelPopoverController.dispose();
    _modelSearchController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<DashboardProvider>().sendMessage(message);
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dashboard = context.watch<DashboardProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentSession = dashboard.currentSession;
    final personaIcon = _getPersonaIcon(themeProvider.chatPersonaIcon);
    final hasApiKey =
        themeProvider.apiKey != null && themeProvider.apiKey!.isNotEmpty;

    return Row(
      children: [
        // Chat History Sidebar (25%)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withOpacity(0.2),
            border: Border(right: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Column(
            children: [
              // History Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chat History',
                          style: theme.textTheme.large.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Only show New button if current session has messages
                        if (currentSession != null &&
                            currentSession.messages.isNotEmpty)
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () => dashboard.createNewSession(),
                            icon: const Icon(Icons.add, size: 14),
                            child: const Text(
                              'New',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    // Clear all button
                    if (dashboard.sessions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showClearAllDialog(context, dashboard),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_sweep_rounded,
                                size: 14,
                                color: theme.colorScheme.destructive,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Clear all conversations',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.destructive,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // History List
              Expanded(
                child:
                    dashboard.sessions.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No conversations yet',
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: dashboard.sessions.length,
                          itemBuilder: (context, index) {
                            final session = dashboard.sessions[index];
                            final isCurrent =
                                dashboard.currentSession?.id == session.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => dashboard.selectSession(session),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrent
                                            ? theme.colorScheme.accent
                                            : theme.colorScheme.card,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isCurrent
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.border,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              session.title,
                                              style: theme.textTheme.small
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCurrent)
                                            Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: theme.colorScheme.primary,
                                            ),
                                          const SizedBox(width: 8),
                                          // Delete button
                                          InkWell(
                                            onTap: () {
                                              // Prevent selecting the session when deleting
                                              _showDeleteDialog(
                                                context,
                                                session,
                                                dashboard,
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 14,
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .destructive,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${session.messages.length} messages',
                                        style: theme.textTheme.muted.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),

        // Main Chat Area (75%)
        Expanded(
          child: Column(
            children: [
              // Chat Header
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
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentSession?.title ?? 'New Conversation',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

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
                            dashboard.modelFilter,
                            (filter) => dashboard.setModelFilter(filter),
                          ),
                          _buildFilterButton(
                            theme,
                            'Fast',
                            Icons.flash_on_rounded,
                            ModelFilter.fast,
                            dashboard.modelFilter,
                            (filter) => dashboard.setModelFilter(filter),
                          ),
                          _buildFilterButton(
                            theme,
                            'All',
                            Icons.list_rounded,
                            ModelFilter.all,
                            dashboard.modelFilter,
                            (filter) => dashboard.setModelFilter(filter),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Model Selector
                    ShadPopover(
                      controller: _modelPopoverController,
                      child: ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: _modelPopoverController.toggle,
                        decoration: ShadDecoration(
                          color: theme.colorScheme.secondary,
                        ),
                        icon: Icon(personaIcon, size: 16),
                        child: Text(
                          dashboard.selectedModel?.name ?? 'Select Model',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      popover: (context) {
                        // Filter models based on search query
                        final availableModels = dashboard.availableModels;
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
                              if (dashboard.modelFilter == ModelFilter.fast ||
                                  dashboard.modelFilter == ModelFilter.all) ...[
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
                                        style: theme.textTheme.muted.copyWith(
                                          fontSize: 11,
                                        ),
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
                                            style: theme.textTheme.small
                                                .copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: theme.colorScheme.border,
                                ),
                              ],
                              // Model list
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredModels.length,
                                  itemBuilder: (context, index) {
                                    final model = filteredModels[index];
                                    final isSelected =
                                        dashboard.selectedModel?.id == model.id;

                                    return InkWell(
                                      onTap: () {
                                        dashboard.selectModel(model);
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
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? theme.colorScheme.accent
                                                  : Colors.transparent,
                                          border:
                                              index < filteredModels.length - 1
                                                  ? Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .border,
                                                      width: 0.5,
                                                    ),
                                                  )
                                                  : null,
                                        ),
                                        child: Row(
                                          children: [
                                            if (isSelected)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    model.name,
                                                    style: theme.textTheme.small
                                                        .copyWith(
                                                          fontWeight:
                                                              isSelected
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w500,
                                                        ),
                                                  ),
                                                  if (model
                                                      .description
                                                      .isNotEmpty)
                                                    Text(
                                                      model.description,
                                                      style: theme
                                                          .textTheme
                                                          .muted
                                                          .copyWith(
                                                            fontSize: 10,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Messages Area
              Expanded(
                child:
                    currentSession == null || currentSession.messages.isEmpty
                        ? _buildEmptyState(theme, dashboard)
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24),
                          itemCount: currentSession.messages.length,
                          itemBuilder: (context, index) {
                            final message = currentSession.messages[index];
                            final isUser = message.role == 'user';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  if (!isUser) ...[
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        personaIcon,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            isUser
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.muted
                                                    .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isUser ? 'You' : 'AI Assistant',
                                            style: theme.textTheme.small
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      isUser
                                                          ? theme
                                                              .colorScheme
                                                              .primaryForeground
                                                          : theme
                                                              .colorScheme
                                                              .foreground,
                                                  fontSize: 11,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Use Markdown for AI responses, plain Text for user
                                          if (isUser)
                                            Text(
                                              message.content,
                                              style: theme.textTheme.small
                                                  .copyWith(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primaryForeground,
                                                  ),
                                            )
                                          else
                                            MarkdownBody(
                                              data:
                                                  message.content.isEmpty
                                                      ? '...'
                                                      : message.content,
                                              styleSheet: MarkdownStyleSheet(
                                                p: theme.textTheme.small
                                                    .copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .foreground,
                                                    ),
                                                code: theme.textTheme.small
                                                    .copyWith(
                                                      fontFamily: 'monospace',
                                                      backgroundColor:
                                                          theme
                                                              .colorScheme
                                                              .muted,
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .foreground,
                                                    ),
                                                codeblockDecoration:
                                                    BoxDecoration(
                                                      color: theme
                                                          .colorScheme
                                                          .muted
                                                          .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .border,
                                                      ),
                                                    ),
                                                codeblockPadding:
                                                    const EdgeInsets.all(12),
                                                h1: theme.textTheme.h3.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .foreground,
                                                ),
                                                h2: theme.textTheme.h4.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .foreground,
                                                ),
                                                blockquote: theme
                                                    .textTheme
                                                    .small
                                                    .copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .foreground
                                                          .withOpacity(0.7),
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                blockquoteDecoration:
                                                    BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .primary,
                                                          width: 4,
                                                        ),
                                                      ),
                                                    ),
                                                listBullet: theme
                                                    .textTheme
                                                    .small
                                                    .copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .foreground,
                                                    ),
                                              ),
                                              selectable: true,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isUser) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 20,
                                        color:
                                            theme.colorScheme.primaryForeground,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
              ),

              // Loading Indicator
              if (dashboard.isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI is thinking...',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // Error Message
              if (dashboard.error != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.destructive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.destructive.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.destructive,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dashboard.error!,
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.destructive,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => dashboard.clearError(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Shortcuts(
                        shortcuts: {
                          const SingleActivator(LogicalKeyboardKey.enter):
                              const _SendMessageIntent(),
                        },
                        child: Actions(
                          actions: {
                            _SendMessageIntent:
                                CallbackAction<_SendMessageIntent>(
                                  onInvoke: (_) {
                                    if (!HardwareKeyboard
                                            .instance
                                            .isShiftPressed &&
                                        !dashboard.isLoading) {
                                      _sendMessage();
                                    }
                                    return null;
                                  },
                                ),
                          },
                          child: Focus(
                            child: ShadInput(
                              controller: _messageController,
                              placeholder: Text(
                                hasApiKey
                                    ? 'Type your message... (Enter to send, Shift+Enter for new line)'
                                    : 'API key required - Go to Settings to add one',
                              ),
                              enabled: hasApiKey && !dashboard.isLoading,
                              maxLines: 5,
                              minLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShadButton(
                      onPressed:
                          (hasApiKey && !dashboard.isLoading)
                              ? _sendMessage
                              : null,
                      icon: Icon(
                        Icons.send_rounded,
                        size: 18,
                        color:
                            (!hasApiKey || dashboard.isLoading)
                                ? theme.colorScheme.foreground.withOpacity(0.3)
                                : theme.colorScheme.primaryForeground,
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ShadThemeData theme, DashboardProvider dashboard) {
    final themeProvider = context.read<ThemeProvider>();
    final hasApiKey =
        themeProvider.apiKey != null && themeProvider.apiKey!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  hasApiKey
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.destructive.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasApiKey
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.key_off_rounded,
              size: 48,
              color:
                  hasApiKey
                      ? theme.colorScheme.primary
                      : theme.colorScheme.destructive,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasApiKey ? 'Start a Conversation' : 'API Key Required',
            style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hasApiKey
                ? (dashboard.selectedModel != null
                    ? 'Using ${dashboard.selectedModel!.name}'
                    : 'Select a model to get started')
                : 'Please add your OpenRouter API key in Settings to use the chat',
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ChatSession session,
    DashboardProvider dashboard,
  ) {
    final theme = ShadTheme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.background,
          title: Text(
            'Delete Conversation',
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete "${session.title}"? This action cannot be undone.',
            style: theme.textTheme.small,
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              decoration: ShadDecoration(color: theme.colorScheme.secondary),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ShadButton(
              onPressed: () {
                dashboard.deleteSession(session.id);
                Navigator.of(dialogContext).pop();
              },
              decoration: ShadDecoration(color: theme.colorScheme.destructive),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context, DashboardProvider dashboard) {
    final theme = ShadTheme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.background,
          title: Text(
            'Clear All Conversations',
            style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete all ${dashboard.sessions.length} conversations? This action cannot be undone.',
            style: theme.textTheme.small,
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              decoration: ShadDecoration(color: theme.colorScheme.secondary),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ShadButton(
              onPressed: () {
                dashboard.clearAllSessions();
                Navigator.of(dialogContext).pop();
              },
              decoration: ShadDecoration(color: theme.colorScheme.destructive),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButton(
    ShadThemeData theme,
    String label,
    IconData icon,
    ModelFilter filter,
    ModelFilter currentFilter,
    Function(ModelFilter) onTap,
  ) {
    final isSelected = filter == currentFilter;
    return InkWell(
      onTap: () => onTap(filter),
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
}
