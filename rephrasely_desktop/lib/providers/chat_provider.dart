import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/ai_model.dart';
import '../services/openrouter_service.dart';

class ChatProvider extends ChangeNotifier {
  final OpenRouterService _openRouterService = OpenRouterService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  AIModel? _selectedModel;
  List<AIModel> _availableModels = [];
  List<AIModel> _allModels = [];
  bool _modelsLoaded = false;
  bool _showAllModels = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AIModel? get selectedModel => _selectedModel;
  bool get showAllModels => _showAllModels;
  List<AIModel> get availableModels =>
      _modelsLoaded
          ? (_showAllModels ? _allModels : _availableModels)
          : AIModel.getAvailableModels();

  ChatProvider() {
    _selectedModel = AIModel.getAvailableModels().first;
  }

  void setApiKey(String apiKey) {
    _openRouterService.setApiKey(apiKey);
    loadAvailableModels();
  }

  void toggleShowAllModels() {
    _showAllModels = !_showAllModels;
    notifyListeners();
  }

  Future<void> loadAvailableModels() async {
    print('ChatProvider: Starting to load models...');
    try {
      // Load top priority models
      final topModels = await _openRouterService.getTopModels(limit: 10);
      // Load ALL models
      final allModelsData = await _openRouterService.getAllModels();

      print('ChatProvider: Top models: ${topModels.length}');
      print('ChatProvider: All models: ${allModelsData.length}');

      if (topModels.isNotEmpty) {
        _availableModels =
            topModels.map((m) {
              return AIModel(
                id: m['id'] as String? ?? '',
                name: m['name'] as String? ?? m['id'] as String? ?? 'Unknown',
                description: m['description'] as String? ?? '',
              );
            }).toList();

        _allModels =
            allModelsData.map((m) {
              return AIModel(
                id: m['id'] as String? ?? '',
                name: m['name'] as String? ?? m['id'] as String? ?? 'Unknown',
                description: m['description'] as String? ?? '',
              );
            }).toList();

        _modelsLoaded = true;

        // Set first model as default
        if (_selectedModel == null && _availableModels.isNotEmpty) {
          _selectedModel = _availableModels.first;
        }
        notifyListeners();
      } else {
        print('ChatProvider: No models received, using fallback');
        _availableModels = AIModel.getAvailableModels();
        _allModels = AIModel.getAvailableModels();
        _modelsLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      print('ChatProvider: Error loading models: $e');
      _availableModels = AIModel.getAvailableModels();
      _allModels = AIModel.getAvailableModels();
      _modelsLoaded = true;
      notifyListeners();
    }
  }

  void selectModel(AIModel model) {
    // If changing to a different model, clear chat history
    if (_selectedModel?.id != model.id) {
      _messages.clear();
      _error = null;
      print('🔄 Switched to ${model.name} - Chat history cleared');
    }
    _selectedModel = model;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _selectedModel == null) return;

    _error = null;

    // Add user message
    final userMessage = ChatMessage(role: 'user', content: content);
    _messages.add(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _openRouterService.sendChatCompletion(
        messages: _messages,
        model: _selectedModel!.id,
      );

      if (response != null) {
        final assistantMessage = ChatMessage(
          role: 'assistant',
          content: response,
        );
        _messages.add(assistantMessage);
      } else {
        _error = 'No response received from the API';
      }
    } catch (e) {
      _error = e.toString();
      // Remove the user message if the request failed
      _messages.removeLast();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
