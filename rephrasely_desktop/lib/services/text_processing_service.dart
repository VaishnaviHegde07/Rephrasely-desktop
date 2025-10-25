import '../models/hotkey.dart';
import '../models/chat_message.dart';
import '../services/openrouter_service.dart';
import '../utils/prompt_templates.dart';

/// Service for processing text transformations using AI
class TextProcessingService {
  final OpenRouterService _openRouterService;

  TextProcessingService(this._openRouterService);

  /// Process text based on hotkey configuration
  Future<String> processText({
    required String text,
    required Hotkey hotkey,
  }) async {
    print('🤖 TextProcessingService: Processing text with ${hotkey.name}');
    print(
      '📝 TextProcessingService: Original text length: ${text.length} chars',
    );

    // Build the prompt using PromptTemplates
    final prompt = PromptTemplates.getPrompt(
      actionType: hotkey.actionType,
      style: hotkey.style,
      customPrompt: hotkey.customPrompt,
      text: text,
    );

    print(
      '📋 TextProcessingService: Using ${hotkey.actionType.displayName} prompt',
    );

    try {
      // Call OpenRouter API
      final response = await _openRouterService.sendChatCompletion(
        model: hotkey.modelId,
        messages: [ChatMessage(role: 'user', content: prompt)],
      );

      if (response == null || response.trim().isEmpty) {
        throw Exception('Empty response from AI');
      }

      print(
        '✅ TextProcessingService: Received response (${response.length} chars)',
      );
      return response.trim();
    } catch (e) {
      print('❌ TextProcessingService: Error - $e');
      throw Exception('Failed to process text: $e');
    }
  }

  /// Validate that text is suitable for processing
  bool validateText(String text) {
    if (text.isEmpty) {
      print('⚠️ TextProcessingService: Text is empty');
      return false;
    }

    if (text.length > 10000) {
      print('⚠️ TextProcessingService: Text too long (${text.length} chars)');
      return false;
    }

    return true;
  }
}
