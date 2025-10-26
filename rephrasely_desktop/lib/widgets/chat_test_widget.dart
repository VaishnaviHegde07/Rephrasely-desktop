import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';

class ChatTestWidget extends StatefulWidget {
  const ChatTestWidget({super.key});

  @override
  State<ChatTestWidget> createState() => _ChatTestWidgetState();
}

class _ChatTestWidgetState extends State<ChatTestWidget> {
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

    context.read<ChatProvider>().sendMessage(message);
    _messageController.clear();

    // Scroll to bottom after sending message
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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final availableModels = chatProvider.availableModels;
    final personaIcon = _getPersonaIcon(themeProvider.chatPersonaIcon);

    // Debug: Print model count
    print('ChatTestWidget: Displaying ${availableModels.length} models');

    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with model selector and clear button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
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
                const SizedBox(width: 8),
                Text(
                  'Chat Test',
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Toggle: Top vs All Models
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    context.read<ChatProvider>().toggleShowAllModels();
                  },
                  decoration: ShadDecoration(color: theme.colorScheme.muted),
                  icon: Icon(
                    chatProvider.showAllModels
                        ? Icons.list_rounded
                        : Icons.star_rounded,
                    size: 14,
                  ),
                  child: Text(
                    chatProvider.showAllModels ? 'All' : 'Top',
                    style: const TextStyle(fontSize: 11),
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
                      chatProvider.selectedModel?.name ?? 'Select Model',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  popover: (context) {
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
                          // Search bar (only show when "All" models is selected)
                          if (chatProvider.showAllModels) ...[
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredModels.length,
                              itemBuilder: (context, index) {
                                final model = filteredModels[index];
                                final isSelected =
                                    chatProvider.selectedModel?.id == model.id;

                                return InkWell(
                                  onTap: () {
                                    context.read<ChatProvider>().selectModel(
                                      model,
                                    );
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
                                                      theme.colorScheme.border,
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
                                              color: theme.colorScheme.primary,
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
                                                              ? FontWeight.w600
                                                              : FontWeight.w500,
                                                    ),
                                              ),
                                              if (model.description.isNotEmpty)
                                                Text(
                                                  model.description,
                                                  style: theme.textTheme.muted
                                                      .copyWith(fontSize: 10),
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
                const SizedBox(width: 8),
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    context.read<ChatProvider>().clearChat();
                  },
                  decoration: ShadDecoration(
                    color: theme.colorScheme.destructive,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Chat messages
          Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            child:
                chatProvider.messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_rounded,
                            size: 48,
                            color: theme.colorScheme.muted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start a conversation to test your API key',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[index];
                        final isUser = message.role == 'user';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      isUser
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            isUser
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.muted,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        message.content,
                                        style: theme.textTheme.small.copyWith(
                                          color:
                                              isUser
                                                  ? Colors.white
                                                  : theme
                                                      .colorScheme
                                                      .foreground,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 12),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.accent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Loading indicator
          if (chatProvider.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Thinking...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (chatProvider.error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatProvider.error!,
                      style: theme.textTheme.small.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              border: Border(top: BorderSide(color: theme.colorScheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShadInput(
                    controller: _messageController,
                    placeholder: const Text('Type your message...'),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !chatProvider.isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                ShadButton(
                  onPressed: chatProvider.isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
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
