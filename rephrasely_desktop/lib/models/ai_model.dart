class AIModel {
  final String id;
  final String name;
  final String description;

  AIModel({required this.id, required this.name, required this.description});

  static List<AIModel> getAvailableModels() {
    return [
      AIModel(
        id: 'openai/gpt-4o',
        name: 'GPT-4O',
        description: 'Most capable model for complex reasoning',
      ),
      AIModel(
        id: 'anthropic/claude-3.5-sonnet',
        name: 'Claude 3.5 Sonnet',
        description: 'Excellent for writing and analysis',
      ),
      AIModel(
        id: 'openai/gpt-4o-mini',
        name: 'GPT-4O Mini',
        description: 'Fast and affordable, great balance',
      ),
      AIModel(
        id: 'google/gemini-pro-1.5',
        name: 'Gemini Pro 1.5',
        description: 'Google\'s latest with huge context',
      ),
      AIModel(
        id: 'meta-llama/llama-3.3-70b-instruct',
        name: 'Llama 3.3 70B',
        description: 'Open-source, powerful and fast',
      ),
    ];
  }
}
