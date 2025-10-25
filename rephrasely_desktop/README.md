# Rephrasely Desktop

A professional macOS desktop application built with Flutter and shadcn_ui for managing AI-powered text rephrasing with OpenRouter API integration.

## Features

### 🎨 Modern UI
- Built with **shadcn_ui** components for a clean and professional interface
- Light and dark theme support with instant switching
- Web-style app bar with dropdown menus
- Responsive and user-friendly design

### ⚙️ Settings Management

#### 1. OpenRouter API Configuration
- Secure API key storage using SharedPreferences
- Real-time API key validation
- Interactive chatbot test interface to verify API functionality
- Support for multiple AI models:
  - GPT-4O & GPT-4O Mini
  - GPT-3.5 Turbo
  - Claude 3.5 Sonnet & Claude 3 Opus
  - Google Gemini Pro

#### 2. Theme Customization
- Toggle between light and dark themes
- Visual theme preview
- Persistent theme preferences
- Smooth theme transitions

### 🤖 Chat Test Interface
- Full-featured chat interface for testing API keys
- Model selection dropdown
- Real-time message streaming
- Error handling and status indicators
- Clear chat history functionality

### 📱 Application Structure
- **Dashboard**: Main workspace overview (placeholder for future features)
- **Settings Menu**: 
  - OpenRouter API Keys configuration
  - App Theme settings
- **Hotkeys Menu**: Keyboard shortcuts management (placeholder for future features)

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- macOS development environment
- OpenRouter API key ([Get one here](https://openrouter.ai))

### Installation

1. Clone the repository:
```bash
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d macos
```

## Usage

### Setting Up Your API Key

1. Launch the application
2. Click on **Settings** in the app bar
3. Select **OpenRouter API Keys**
4. Enter your API key in the input field
5. Click **Save & Test API Key** to validate
6. Optionally, click **Test with Chatbot** to verify functionality

### Testing the API

1. After saving your API key, click **Test with Chatbot**
2. Select an AI model from the dropdown
3. Type your message in the input field
4. Click **Send** or press Enter
5. View the AI's response in the chat interface

### Changing Theme

1. Click on **Settings** in the app bar
2. Select **App Theme**
3. Choose between **Light** or **Dark** theme
4. The theme will apply immediately

## Architecture

### Project Structure
```
lib/
├── main.dart                   # App entry point
├── models/                     # Data models
│   ├── chat_message.dart
│   ├── app_settings.dart
│   └── ai_model.dart
├── services/                   # Business logic
│   ├── storage_service.dart
│   └── openrouter_service.dart
├── providers/                  # State management
│   ├── theme_provider.dart
│   ├── app_state_provider.dart
│   └── chat_provider.dart
├── screens/                    # UI screens
│   ├── main_screen.dart
│   ├── dashboard/
│   ├── settings/
│   └── hotkeys/
└── widgets/                    # Reusable components
    ├── app_menu_bar.dart
    └── chat_test_widget.dart
```

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **shadcn_ui**: Professional UI component library
- **Provider**: State management
- **SharedPreferences**: Local data persistence
- **HTTP**: API communication

## API Integration

The application integrates with OpenRouter's API according to their [official documentation](https://openrouter.ai/docs/quickstart):

- Base URL: `https://openrouter.ai/api/v1`
- Authentication: Bearer token
- Endpoints:
  - `/models` - List available models
  - `/chat/completions` - Send chat messages

## Future Enhancements

- [ ] Complete Dashboard with analytics
- [ ] Hotkey configuration and management
- [ ] Text rephrasing features
- [ ] History and favorites
- [ ] Export/Import settings
- [ ] Multiple API provider support

## License

This project is private and not licensed for public use.

## Support

For issues or questions, please contact the development team.
