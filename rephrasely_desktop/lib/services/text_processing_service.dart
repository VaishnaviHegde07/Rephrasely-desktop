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
      // System prompt to enforce clean output
      const systemPrompt =
          '''You are a text transformation tool. Your sole purpose is to output the transformed text and nothing else.

CRITICAL INSTRUCTIONS:
- Do NOT add any introductions, explanations, or commentary
- Do NOT say "Here is the text" or similar phrases
- Do NOT use quotation marks around the output
- Output ONLY the transformed text itself
- Start your response immediately with the transformed text''';

      // Call OpenRouter API with system prompt
      final response = await _openRouterService.sendChatCompletion(
        model: hotkey.modelId,
        messages: [ChatMessage(role: 'user', content: prompt)],
        systemPrompt: systemPrompt,
      );

      if (response == null || response.trim().isEmpty) {
        throw Exception('Empty response from AI');
      }

      print(
        '✅ TextProcessingService: Received response (${response.length} chars)',
      );

      // Clean the response from any AI artifacts
      final cleanedResponse = _cleanAIResponse(response);

      print(
        '🧹 TextProcessingService: Cleaned response (${cleanedResponse.length} chars)',
      );

      return cleanedResponse;
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

  /// Clean AI response from common artifacts and unwanted formatting
  String _cleanAIResponse(String response) {
    String cleaned = response.trim();

    // Remove thinking/reasoning tags (used by models like DeepSeek)
    cleaned = cleaned.replaceAll(
      RegExp(r'<think>.*?</think>', dotAll: true),
      '',
    );

    // Remove any remaining XML-like tags
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]+>'), '');

    // Remove common AI prefixes
    final prefixes = [
      'Here is the rephrased text:',
      'Here is the text:',
      'Here is the result:',
      'Here is the transformed text:',
      'Here is the corrected text:',
      'Here is the summary:',
      'Here is the expanded text:',
      'Rephrased text:',
      'Transformed text:',
      'Result:',
      'Output:',
      'Answer:',
    ];

    for (var prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }

    // Remove surrounding quotes if present
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }

    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'^```[\w]*\n', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n```$', multiLine: true), '');

    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.trim();

    return cleaned;
  }
}
