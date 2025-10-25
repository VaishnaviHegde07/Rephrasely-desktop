import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openrouter_service.dart';
import '../services/storage_service.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../models/usage_stats.dart';
import '../models/ai_model.dart';
import '../models/hotkey.dart';

class DashboardProvider extends ChangeNotifier {
  final OpenRouterService _openRouterService = OpenRouterService();
  final StorageService _storageService = StorageService();

  UsageStats _stats = UsageStats();
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  AIModel? _selectedModel;
  List<AIModel> _topModels = [];
  List<AIModel> _allModels = [];
  bool _showAllModels = false;
  List<Hotkey> _hotkeys = [];
  Map<String, dynamic>? _creditInfo;

  UsageStats get stats => _stats;
  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AIModel? get selectedModel => _selectedModel;
  List<AIModel> get availableModels => _showAllModels ? _allModels : _topModels;
  List<AIModel> get allModels => _allModels;
  List<AIModel> get topModels => _topModels;
  bool get showAllModels => _showAllModels;
  List<Hotkey> get hotkeys => _hotkeys;
  Map<String, dynamic>? get creditInfo => _creditInfo;

  DashboardProvider() {
    _loadData();
  }

  void setApiKey(String apiKey) {
    _openRouterService.setApiKey(apiKey);
    loadAvailableModels();
    loadCreditInfo();
  }

  Future<void> _loadData() async {
    // Load API key first, then load other data
    await _loadApiKeyAndModels();
    await Future.wait([_loadStats(), _loadSessions(), _loadHotkeys()]);
  }

  Future<void> _loadApiKeyAndModels() async {
    try {
      final settings = await _storageService.loadSettings();
      if (settings.openRouterApiKey != null &&
          settings.openRouterApiKey!.isNotEmpty) {
        print('DashboardProvider: Found saved API key, loading models...');
        _openRouterService.setApiKey(settings.openRouterApiKey!);
        await Future.wait([loadAvailableModels(), loadCreditInfo()]);
      } else {
        print('DashboardProvider: No API key found in settings');
      }
    } catch (e) {
      print('DashboardProvider: Error loading API key: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('usage_stats');
      if (statsJson != null) {
        _stats = UsageStats.fromJson(jsonDecode(statsJson));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usage_stats', jsonEncode(_stats.toJson()));
    } catch (e) {
      print('Error saving stats: $e');
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString('chat_sessions');
      if (sessionsJson != null) {
        final List<dynamic> sessionsList = jsonDecode(sessionsJson);
        _sessions =
            sessionsList
                .map(
                  (json) => ChatSession.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        // Sort by last updated
        _sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

        // Load the most recent session as current
        if (_sessions.isNotEmpty) {
          _currentSession = _sessions.first;
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = jsonEncode(
        _sessions.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('chat_sessions', sessionsJson);
    } catch (e) {
      print('Error saving sessions: $e');
    }
  }

  Future<void> _loadHotkeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hotkeysJson = prefs.getString('hotkeys');
      if (hotkeysJson != null) {
        final List<dynamic> hotkeysList = jsonDecode(hotkeysJson);
        _hotkeys =
            hotkeysList
                .map((json) => Hotkey.fromJson(json as Map<String, dynamic>))
                .toList();

        // Update stats with hotkey count
        _stats = _stats.copyWith(hotkeysRegistered: _hotkeys.length);

        notifyListeners();
      }
    } catch (e) {
      print('Error loading hotkeys: $e');
    }
  }

  // ignore: unused_element
  Future<void> _saveHotkeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hotkeysJson = jsonEncode(_hotkeys.map((h) => h.toJson()).toList());
      await prefs.setString('hotkeys', hotkeysJson);

      // Update stats
      _stats = _stats.copyWith(hotkeysRegistered: _hotkeys.length);
      await _saveStats();
    } catch (e) {
      print('Error saving hotkeys: $e');
    }
  }

  Future<void> loadAvailableModels() async {
    try {
      print('DashboardProvider: Loading available models...');

      // Load top models
      final topModelsData = await _openRouterService.getTopModels(limit: 10);
      _topModels =
          topModelsData.map((m) {
            return AIModel(
              id: m['id'] as String? ?? '',
              name: m['name'] as String? ?? m['id'] as String? ?? 'Unknown',
              description: m['description'] as String? ?? '',
            );
          }).toList();

      // Load all models
      final allModelsData = await _openRouterService.getAllModels();
      _allModels =
          allModelsData.map((m) {
            return AIModel(
              id: m['id'] as String? ?? '',
              name: m['name'] as String? ?? m['id'] as String? ?? 'Unknown',
              description: m['description'] as String? ?? '',
            );
          }).toList();

      // Set default selected model
      if (_selectedModel == null && _topModels.isNotEmpty) {
        _selectedModel = _topModels.first;
        print(
          'DashboardProvider: Set default model to ${_selectedModel!.name}',
        );
      }

      print(
        'DashboardProvider: Loaded ${_topModels.length} top models and ${_allModels.length} all models',
      );
      notifyListeners();
    } catch (e) {
      print('DashboardProvider: Error loading models: $e');
    }
  }

  void toggleShowAllModels() {
    _showAllModels = !_showAllModels;
    notifyListeners();
  }

  void selectModel(AIModel model) {
    print('DashboardProvider: Selecting model ${model.name} (${model.id})');

    // If changing model and current session has messages, create new session
    if (_selectedModel?.id != model.id &&
        _currentSession != null &&
        _currentSession!.messages.isNotEmpty) {
      print(
        'DashboardProvider: Model changed with existing messages, creating new session',
      );
      _selectedModel = model;
      createNewSession();
    } else {
      print('DashboardProvider: Model selected, updating state');
      _selectedModel = model;
      notifyListeners();
    }
  }

  void createNewSession() {
    final now = DateTime.now();
    final newSession = ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'Chat ${_sessions.length + 1}',
      createdAt: now,
      lastUpdated: now,
      messages: [],
      modelId: _selectedModel?.id,
    );

    _sessions.insert(0, newSession);
    _currentSession = newSession;
    _error = null;

    notifyListeners();
    _saveSessions();
  }

  void selectSession(ChatSession session) {
    _currentSession = session;
    _error = null;
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);

    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
    }

    notifyListeners();
    _saveSessions();
  }

  void clearAllSessions() {
    _sessions.clear();
    _currentSession = null;
    _error = null;

    // Reset message count and tokens when clearing all conversations
    _stats = _stats.copyWith(messagesCount: 0, tokensUsed: 0);

    notifyListeners();
    _saveSessions();
    _saveStats();
  }

  void renameSession(String sessionId, String newTitle) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(title: newTitle);

      if (_currentSession?.id == sessionId) {
        _currentSession = _sessions[index];
      }

      notifyListeners();
      _saveSessions();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentSession == null) {
      createNewSession();
    }

    if (_selectedModel == null) {
      _error = 'Please select a model';
      notifyListeners();
      return;
    }

    // Add user message
    final userMessage = ChatMessage(role: 'user', content: content);
    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      lastUpdated: DateTime.now(),
    );

    // Update the session in the list
    int index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      _sessions[index] = _currentSession!;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Create placeholder for assistant message
    final assistantMessage = ChatMessage(role: 'assistant', content: '');
    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, assistantMessage],
      lastUpdated: DateTime.now(),
    );

    index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (index != -1) {
      _sessions[index] = _currentSession!;
    }

    _isLoading = false;
    notifyListeners();

    try {
      String fullResponse = '';

      await for (var chunk in _openRouterService.sendChatCompletionStream(
        messages: _currentSession!.messages.sublist(
          0,
          _currentSession!.messages.length - 1,
        ),
        model: _selectedModel!.id,
      )) {
        fullResponse += chunk;

        // Update the last message with accumulated content
        final messages = List<ChatMessage>.from(_currentSession!.messages);
        messages[messages.length - 1] = ChatMessage(
          role: 'assistant',
          content: fullResponse,
        );

        _currentSession = _currentSession!.copyWith(
          messages: messages,
          lastUpdated: DateTime.now(),
        );

        // Update in list
        final idx = _sessions.indexWhere((s) => s.id == _currentSession!.id);
        if (idx != -1) {
          _sessions[idx] = _currentSession!;
        }

        notifyListeners();
      }

      // Generate title from first message if still using default
      if (_currentSession!.messages.length == 2 &&
          _currentSession!.title.startsWith('Chat ')) {
        final newTitle = _generateChatTitle(content);
        _currentSession = _currentSession!.copyWith(title: newTitle);

        final idx = _sessions.indexWhere((s) => s.id == _currentSession!.id);
        if (idx != -1) {
          _sessions[idx] = _currentSession!;
        }
      }

      // Update stats
      _stats = _stats.copyWith(
        messagesCount: _stats.messagesCount + 2,
        tokensUsed:
            _stats.tokensUsed +
            _estimateTokens(content) +
            _estimateTokens(fullResponse),
        lastUpdated: DateTime.now(),
      );

      await Future.wait([_saveSessions(), _saveStats()]);
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      // Remove the empty assistant message on error
      final messages = List<ChatMessage>.from(_currentSession!.messages);
      if (messages.isNotEmpty &&
          messages.last.role == 'assistant' &&
          messages.last.content.isEmpty) {
        messages.removeLast();
        _currentSession = _currentSession!.copyWith(messages: messages);

        final idx = _sessions.indexWhere((s) => s.id == _currentSession!.id);
        if (idx != -1) {
          _sessions[idx] = _currentSession!;
        }
      }
      notifyListeners();
    }
  }

  String _generateChatTitle(String firstMessage) {
    // Clean and truncate the first message to create a title
    String title = firstMessage.trim();

    // Remove line breaks
    title = title.replaceAll(RegExp(r'\s+'), ' ');

    // Truncate to max 50 characters
    if (title.length > 50) {
      title = '${title.substring(0, 47)}...';
    }

    // Capitalize first letter
    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }

    return title.isEmpty ? 'New Conversation' : title;
  }

  int _estimateTokens(String text) {
    // Rough estimation: 1 token ≈ 4 characters
    return (text.length / 4).ceil();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadCreditInfo() async {
    try {
      print('DashboardProvider: Loading credit info...');
      _creditInfo = await _openRouterService.getCredits();
      if (_creditInfo != null) {
        print('DashboardProvider: Credit info loaded: $_creditInfo');
      }
      notifyListeners();
    } catch (e) {
      print('Error loading credit info: $e');
    }
  }
}
