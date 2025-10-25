import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  // Singleton pattern
  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    print('🔑 OpenRouterService: API key set');
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Get API credit information
  Future<Map<String, dynamic>?> getCredits() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/key'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('💳 OpenRouterService: Fetched credit info');

        // OpenRouter returns data in 'data' field
        final creditData = data['data'] as Map<String, dynamic>?;
        return creditData;
      } else {
        print('❌ Error fetching credits: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching credits: $e');
    }

    return null;
  }

  /// Test if the API key is valid by making a simple request
  Future<bool> testApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error testing API key: $e');
      return false;
    }
  }

  /// Send a chat completion request to OpenRouter
  Future<String?> sendChatCompletion({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set');
    }

    // Build messages array with optional system prompt
    final messagesPayload = _buildMessagesWithSystem(messages, systemPrompt);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'rephrasely-desktop',
          'X-Title': 'Rephrasely Desktop',
        },
        body: jsonEncode({'model': model, 'messages': messagesPayload}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>;

        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          return message['content'] as String?;
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'API Error: ${errorBody['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error sending chat completion: $e');
      rethrow;
    }

    return null;
  }

  /// Send a streaming chat completion request to OpenRouter
  Stream<String> sendChatCompletionStream({
    required List<ChatMessage> messages,
    required String model,
    String? systemPrompt,
  }) async* {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set');
    }

    // Build messages array with optional system prompt
    final messagesPayload = _buildMessagesWithSystem(messages, systemPrompt);

    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'rephrasely-desktop',
        'X-Title': 'Rephrasely Desktop',
      });

      request.body = jsonEncode({
        'model': model,
        'messages': messagesPayload,
        'stream': true,
      });

      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode == 200) {
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          // Parse SSE format: "data: {...}\n\n"
          final lines = chunk.split('\n');

          for (var line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();

              if (data == '[DONE]') {
                break;
              }

              try {
                final json = jsonDecode(data);
                final choices = json['choices'] as List<dynamic>;

                if (choices.isNotEmpty) {
                  final delta = choices[0]['delta'] as Map<String, dynamic>;
                  final content = delta['content'] as String?;

                  if (content != null) {
                    yield content;
                  }
                }
              } catch (e) {
                // Skip malformed JSON chunks
                continue;
              }
            }
          }
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }

      client.close();
    } catch (e) {
      print('Error sending streaming chat completion: $e');
      rethrow;
    }
  }

  /// Get available models from OpenRouter (top models by default)
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    return await getTopModels(limit: 10);
  }

  /// Get ALL models without filtering
  Future<List<Map<String, dynamic>>> getAllModels() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
    } catch (e) {
      print('❌ Error getting all models: $e');
    }

    return [];
  }

  /// Get top models dynamically from OpenRouter API
  Future<List<Map<String, dynamic>>> getTopModels({int limit = 10}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final modelsList = List<Map<String, dynamic>>.from(data['data'] ?? []);

        print('✅ Fetched ${modelsList.length} models from OpenRouter');

        // Filter to get top models
        final topModels = _selectTopModels(modelsList, limit);

        print('📊 Selected top ${topModels.length} models');

        return topModels;
      } else {
        print('❌ Error response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }

    return [];
  }

  /// Dynamically select top models based on API metadata
  /// No hardcoded lists - ranks by context, pricing, and quality indicators
  List<Map<String, dynamic>> _selectTopModels(
    List<Map<String, dynamic>> allModels,
    int limit,
  ) {
    // Score each model based on multiple factors
    final scoredModels =
        allModels.map((model) {
          double score = 0.0;

          // Factor 1: Context length (max 40 points)
          final contextLength = model['context_length'] as int? ?? 0;
          score += (contextLength / 1000).clamp(0, 40);

          // Factor 2: Pricing - lower is better (max 30 points)
          final promptPrice =
              double.tryParse(
                model['pricing']?['prompt']?.toString() ?? '999',
              ) ??
              999;
          if (promptPrice < 0.01)
            score += 30;
          else if (promptPrice < 0.1)
            score += 20;
          else if (promptPrice < 1)
            score += 10;

          // Factor 3: Model tier detection from name (max 30 points)
          final modelName = (model['name'] as String? ?? '').toLowerCase();
          if (modelName.contains('gpt-4') || modelName.contains('gpt4'))
            score += 30;
          else if (modelName.contains('claude') && modelName.contains('3'))
            score += 28;
          else if (modelName.contains('gemini'))
            score += 25;
          else if (modelName.contains('llama') && modelName.contains('70b'))
            score += 22;
          else if (modelName.contains('mistral'))
            score += 20;

          return {'model': model, 'score': score};
        }).toList();

    // Sort by score descending
    scoredModels.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    // Select top models with provider diversity
    final selected = <Map<String, dynamic>>[];
    final providerCounts = <String, int>{};

    for (var item in scoredModels) {
      if (selected.length >= limit) break;

      final model = item['model'] as Map<String, dynamic>;
      final modelId = model['id'] as String? ?? '';
      final provider = modelId.split('/').first;

      // Max 3 models per provider for diversity
      if ((providerCounts[provider] ?? 0) < 3) {
        selected.add(model);
        providerCounts[provider] = (providerCounts[provider] ?? 0) + 1;
      }
    }

    // Fill remaining slots if needed
    if (selected.length < limit) {
      for (var item in scoredModels) {
        if (selected.length >= limit) break;
        final model = item['model'] as Map<String, dynamic>;
        if (!selected.any((m) => m['id'] == model['id'])) {
          selected.add(model);
        }
      }
    }

    return selected;
  }

  /// Build messages array with optional system prompt prepended
  List<Map<String, dynamic>> _buildMessagesWithSystem(
    List<ChatMessage> messages,
    String? systemPrompt,
  ) {
    final List<Map<String, dynamic>> messagesPayload = [];

    // Add system message if provided
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messagesPayload.add({'role': 'system', 'content': systemPrompt});
    }

    // Add user messages
    messagesPayload.addAll(messages.map((m) => m.toJson()).toList());

    return messagesPayload;
  }
}
