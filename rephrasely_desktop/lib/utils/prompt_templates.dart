import '../models/hotkey.dart';

/// Central repository for AI prompt templates
/// Combines action types with styles to generate effective prompts
class PromptTemplates {
  /// Get the appropriate prompt based on action type, style, and custom prompt
  static String getPrompt({
    required HotkeyActionType actionType,
    HotkeyStyle? style,
    String? customPrompt,
    required String text,
  }) {
    // For custom actions, use the custom prompt directly
    if (actionType == HotkeyActionType.custom) {
      if (customPrompt == null || customPrompt.trim().isEmpty) {
        return 'Process the following text:\n\n$text';
      }
      return '$customPrompt\n\n$text';
    }

    // For preset actions, combine action + style
    if (style == null) {
      // Fallback if style is missing for non-custom actions
      return _getDefaultPrompt(actionType, text);
    }

    return _getCombinedPrompt(actionType, style, text);
  }

  /// Get combined prompt for action + style combination
  static String _getCombinedPrompt(
    HotkeyActionType action,
    HotkeyStyle style,
    String text,
  ) {
    switch (action) {
      case HotkeyActionType.rephrase:
        return _getRephrasePrompt(style, text);
      case HotkeyActionType.fixGrammar:
        return _getGrammarPrompt(style, text);
      case HotkeyActionType.summarize:
        return _getSummarizePrompt(style, text);
      case HotkeyActionType.expand:
        return _getExpandPrompt(style, text);
      case HotkeyActionType.custom:
        return text; // Should not reach here
    }
  }

  // ==================== REPHRASE PROMPTS ====================

  static String _getRephrasePrompt(HotkeyStyle style, String text) {
    switch (style) {
      case HotkeyStyle.professional:
        return '''Rephrase the following text in a professional, formal tone while maintaining its core meaning. Use clear, business-appropriate language, proper grammar, and a polished style suitable for professional communication:

$text

Provide only the rephrased text without any additional commentary or explanation.''';

      case HotkeyStyle.casual:
        return '''Rephrase the following text in a casual, conversational tone. Make it sound natural, friendly, and approachable as if talking to a friend. Use simple, everyday language:

$text

Provide only the rephrased text without any additional commentary or explanation.''';

      case HotkeyStyle.concise:
        return '''Rephrase the following text in a concise, brief manner while keeping all essential information. Eliminate unnecessary words and make it as short as possible without losing meaning:

$text

Provide only the rephrased text without any additional commentary or explanation.''';

      case HotkeyStyle.detailed:
        return '''Rephrase the following text in a more detailed, elaborate manner. Add context, clarity, and additional relevant information to make it more comprehensive and thorough:

$text

Provide only the rephrased text without any additional commentary or explanation.''';
    }
  }

  // ==================== GRAMMAR PROMPTS ====================

  static String _getGrammarPrompt(HotkeyStyle style, String text) {
    switch (style) {
      case HotkeyStyle.professional:
        return '''Fix all grammar, spelling, punctuation, and syntax errors in the following text. Maintain a professional, formal tone with proper business writing conventions:

$text

Provide only the corrected text without any additional commentary or explanation.''';

      case HotkeyStyle.casual:
        return '''Fix all grammar, spelling, and punctuation errors in the following text while keeping a casual, conversational tone. Make it grammatically correct but still sound natural and friendly:

$text

Provide only the corrected text without any additional commentary or explanation.''';

      case HotkeyStyle.concise:
        return '''Fix all grammar, spelling, and punctuation errors in the following text. Make corrections concisely, removing any redundancies:

$text

Provide only the corrected text without any additional commentary or explanation.''';

      case HotkeyStyle.detailed:
        return '''Thoroughly fix all grammar, spelling, punctuation, and syntax errors in the following text. Ensure clarity, proper sentence structure, and comprehensive correctness:

$text

Provide only the corrected text without any additional commentary or explanation.''';
    }
  }

  // ==================== SUMMARIZE PROMPTS ====================

  static String _getSummarizePrompt(HotkeyStyle style, String text) {
    switch (style) {
      case HotkeyStyle.professional:
        return '''Provide a professional, well-structured summary of the following text. Use formal language and highlight key points in a business-appropriate manner:

$text

Provide only the summary without any additional commentary or explanation.''';

      case HotkeyStyle.casual:
        return '''Summarize the following text in a casual, easy-to-understand way. Make it conversational and accessible, as if explaining to a friend:

$text

Provide only the summary without any additional commentary or explanation.''';

      case HotkeyStyle.concise:
        return '''Provide a brief, concise summary of the following text. Include only the most essential points in as few words as possible:

$text

Provide only the summary without any additional commentary or explanation.''';

      case HotkeyStyle.detailed:
        return '''Provide a comprehensive, detailed summary of the following text. Cover all key points, main ideas, and important details thoroughly:

$text

Provide only the summary without any additional commentary or explanation.''';
    }
  }

  // ==================== EXPAND PROMPTS ====================

  static String _getExpandPrompt(HotkeyStyle style, String text) {
    switch (style) {
      case HotkeyStyle.professional:
        return '''Expand the following text with additional professional detail and context. Add relevant information, examples, and elaboration while maintaining a formal, business-appropriate tone:

$text

Provide only the expanded text without any additional commentary or explanation.''';

      case HotkeyStyle.casual:
        return '''Expand the following text with more detail and context in a casual, conversational way. Make it more comprehensive while keeping it friendly and easy to read:

$text

Provide only the expanded text without any additional commentary or explanation.''';

      case HotkeyStyle.concise:
        return '''Expand the following text with additional relevant information while still keeping it relatively concise. Add necessary details without being overly verbose:

$text

Provide only the expanded text without any additional commentary or explanation.''';

      case HotkeyStyle.detailed:
        return '''Significantly expand the following text with comprehensive detail, context, examples, and thorough elaboration. Make it as complete and informative as possible:

$text

Provide only the expanded text without any additional commentary or explanation.''';
    }
  }

  // ==================== FALLBACK PROMPTS ====================

  static String _getDefaultPrompt(HotkeyActionType action, String text) {
    switch (action) {
      case HotkeyActionType.rephrase:
        return 'Rephrase the following text:\n\n$text';
      case HotkeyActionType.fixGrammar:
        return 'Fix all grammar and spelling errors in the following text:\n\n$text';
      case HotkeyActionType.summarize:
        return 'Summarize the following text:\n\n$text';
      case HotkeyActionType.expand:
        return 'Expand the following text with more detail:\n\n$text';
      case HotkeyActionType.custom:
        return text;
    }
  }
}
