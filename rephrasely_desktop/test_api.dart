import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple test script to verify OpenRouter API key
/// Run with: dart test_api.dart
Future<void> main() async {
  print('🔍 Testing OpenRouter API Connection...\n');

  // ⚠️ REPLACE THIS WITH YOUR ACTUAL API KEY
  const apiKey = 'YOUR_API_KEY_HERE';

  if (apiKey == 'YOUR_API_KEY_HERE') {
    print('❌ Please replace YOUR_API_KEY_HERE with your actual API key');
    print('   Get one from: https://openrouter.ai\n');
    return;
  }

  // Test 1: Get available models
  print('📋 Test 1: Fetching available models...');
  await testGetModels(apiKey);
  print('');

  // Test 2: Send a test chat message
  print('💬 Test 2: Sending test chat message...');
  await testChatCompletion(apiKey);
}

Future<void> testGetModels(String apiKey) async {
  const apiUrl = 'https://openrouter.ai/api/v1/models';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['data'] as List;

      print('✅ Success! Total Models Available: ${models.length}');
      print('\n📌 Sample Models:');
      for (var model in models.take(5)) {
        print('   - ${model['id']}');
        print('     Name: ${model['name']}');
      }
    } else {
      print('❌ Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('⚠️  Exception: $e');
  }
}

Future<void> testChatCompletion(String apiKey) async {
  const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'rephrasely-desktop',
    'X-Title': 'Rephrasely Desktop',
  };

  final body = jsonEncode({
    'model': 'openai/gpt-3.5-turbo',
    'messages': [
      {
        'role': 'user',
        'content': 'Say "Hello from Rephrasely!" in a friendly way.',
      },
    ],
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choices = data['choices'] as List;

      if (choices.isNotEmpty) {
        final message = choices[0]['message'];
        final content = message['content'];

        print('✅ Success! AI Response:');
        print('   "$content"');
      }
    } else {
      print('❌ Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('⚠️  Exception: $e');
  }
}
