import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/theme_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/openrouter_service.dart';
import '../../widgets/chat_test_widget.dart';

class OpenRouterApiScreen extends StatefulWidget {
  const OpenRouterApiScreen({super.key});

  @override
  State<OpenRouterApiScreen> createState() => _OpenRouterApiScreenState();
}

class _OpenRouterApiScreenState extends State<OpenRouterApiScreen> {
  final _apiKeyController = TextEditingController();
  final _openRouterService = OpenRouterService();
  bool _isTestingKey = false;
  String? _testResult;
  bool _showChatTest = false;

  @override
  void initState() {
    super.initState();
    final apiKey = context.read<ThemeProvider>().apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text;
    if (apiKey.isEmpty) {
      setState(() {
        _testResult = 'Please enter an API key';
      });
      return;
    }

    setState(() {
      _isTestingKey = true;
      _testResult = null;
    });

    try {
      final isValid = await _openRouterService.testApiKey(apiKey);

      if (isValid) {
        await context.read<ThemeProvider>().saveApiKey(apiKey);
        context.read<ChatProvider>().setApiKey(apiKey);

        setState(() {
          _testResult = 'API key saved successfully!';
          _isTestingKey = false;
        });
      } else {
        setState(() {
          _testResult = 'Invalid API key. Please check and try again.';
          _isTestingKey = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Error testing API key: $e';
        _isTestingKey = false;
      });
    }
  }

  void _toggleChatTest() {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _testResult = 'Please save an API key first';
      });
      return;
    }

    setState(() {
      _showChatTest = !_showChatTest;
      if (_showChatTest) {
        context.read<ChatProvider>().setApiKey(_apiKeyController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OpenRouter API Configuration', style: theme.textTheme.h1),
                const SizedBox(height: 8),
                Text(
                  'Configure your OpenRouter API key to access AI models',
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 32),

                // API Key Card
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Key',
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShadInput(
                        controller: _apiKeyController,
                        placeholder: const Text(
                          'Enter your OpenRouter API key',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ShadButton(
                            onPressed: _isTestingKey ? null : _saveApiKey,
                            child:
                                _isTestingKey
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Save & Test API Key'),
                          ),
                          const SizedBox(width: 12),
                          ShadButton(
                            onPressed: _showChatTest ? null : _toggleChatTest,
                            decoration: ShadDecoration(
                              color: theme.colorScheme.secondary,
                            ),
                            child: const Text('Test with Chatbot'),
                          ),
                        ],
                      ),
                      if (_testResult != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                _testResult!.contains('success')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _testResult!.contains('success')
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          child: Text(
                            _testResult!,
                            style: theme.textTheme.small.copyWith(
                              color:
                                  _testResult!.contains('success')
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Information Card
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to get your API Key',
                            style: theme.textTheme.large.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Visit openrouter.ai and create an account\n'
                        '2. Navigate to the API Keys section\n'
                        '3. Generate a new API key\n'
                        '4. Copy and paste it above',
                        style: theme.textTheme.small,
                      ),
                    ],
                  ),
                ),

                // Chat Test Widget
                if (_showChatTest) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Test Your API Key', style: theme.textTheme.h2),
                      ShadButton(
                        onPressed: _toggleChatTest,
                        decoration: ShadDecoration(
                          color: theme.colorScheme.destructive,
                        ),
                        icon: const Icon(Icons.close, size: 16),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ChatTestWidget(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
