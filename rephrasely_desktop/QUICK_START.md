# Quick Start Guide

## 🚀 Run the Application

### Option 1: macOS (Requires Xcode)
```bash
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
flutter run -d macos
```

### Option 2: Chrome Browser (No Xcode needed!)
```bash
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
flutter run -d chrome
```

### Option 3: Test API Only (No UI)
```bash
# Edit test_api.dart and add your API key first
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
dart test_api.dart
```

## 📋 Quick Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run app
flutter run -d macos

# Build release
flutter build macos --release

# Check for issues
flutter analyze

# Format code
flutter format .
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run -d macos
```

## 🎯 First Time Setup

1. **Get OpenRouter API Key**
   - Visit: https://openrouter.ai
   - Sign up/Login
   - Navigate to API Keys section
   - Generate new key
   - Copy the key

2. **Configure in App**
   - Launch the app
   - Click "Settings" → "OpenRouter API Keys"
   - Paste your API key
   - Click "Save & Test API Key"
   - Should see green success message

3. **Test the Integration**
   - Click "Test with Chatbot"
   - Select a model (e.g., GPT-4O Mini)
   - Type: "Hello, can you hear me?"
   - Click Send
   - Should receive AI response

## 🎨 UI Features Overview

### Top Menu Bar
```
[Rephrasely] [Dashboard] [Settings ▾] [Hotkeys ▾]
```

### Settings Dropdown
- OpenRouter API Keys
  - API key input
  - Save & Test button
  - Test with Chatbot button
  - Instructions card
  
- App Theme
  - Light theme option
  - Dark theme option
  - Live preview

### Chat Test Interface
- Model selector (top right)
- Chat message display
- Message input field
- Send button
- Clear chat button

## 💡 Usage Tips

### Theme Switching
- **Fast Method**: Settings → App Theme → Click Light/Dark card
- **Persistence**: Theme is automatically saved and restored on app restart

### API Testing
- **Quick Test**: Save & Test API Key button (validates key only)
- **Full Test**: Test with Chatbot (interactive conversation)
- **Model Selection**: Click robot icon in chat to select model

### Keyboard Shortcuts (in input fields)
- **Enter**: Send message (in chat)
- **Cmd+A**: Select all text
- **Cmd+C/V**: Copy/Paste

## 📱 Screen Navigation

```
App Launch
    ↓
Dashboard (default screen)
    ↓
[Click Settings menu]
    ↓
Select submenu:
  - OpenRouter API Keys (default)
  - App Theme
    ↓
[Configure and save]
    ↓
[Click Dashboard to return]
```

## 🔧 Configuration Files

### Important Files
- `pubspec.yaml`: Dependencies and project config
- `macos/Runner/DebugProfile.entitlements`: macOS permissions
- `lib/main.dart`: App entry point

### Settings Storage
- Location: `~/Library/Preferences/com.example.rephrasely_desktop.plist`
- Format: Encrypted SharedPreferences
- Contents: API key, theme preference

## 🎨 Customization

### Change App Colors
Edit `lib/main.dart`:
```dart
// For light theme
colorScheme: const ShadBlueColorScheme.light(),

// Available: ShadBlueColorScheme, ShadGrayColorScheme, etc.
```

### Add New AI Models
Edit `lib/models/ai_model.dart`:
```dart
AIModel(
  id: 'provider/model-name',
  name: 'Display Name',
  description: 'Model description',
),
```

## 🐛 Troubleshooting

### "No device found"
```bash
# Check available devices
flutter devices

# Should show: macOS (desktop)
```

### "Build failed"
```bash
# Clean and rebuild
flutter clean
rm -rf build/
flutter pub get
flutter run -d macos
```

### "API key invalid"
- Verify key from openrouter.ai
- Check for extra spaces
- Ensure internet connection
- Try regenerating key

### "Theme not changing"
- Check console for errors
- Try restarting app
- Clear app data:
```bash
rm ~/Library/Preferences/com.example.rephrasely_desktop.plist
```

## 📚 Learn More

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [shadcn_ui Docs](https://pub.dev/packages/shadcn_ui)
- [OpenRouter API](https://openrouter.ai/docs)
- [Provider Package](https://pub.dev/packages/provider)

### Project Documentation
- `README.md`: Project overview and features
- `IMPLEMENTATION_GUIDE.md`: Detailed implementation details
- `QUICK_START.md`: This file

## 🎯 What's Working

✅ App launches successfully  
✅ Menu navigation works  
✅ Settings screens load  
✅ API key can be saved  
✅ API key validation works  
✅ Chat interface displays  
✅ Messages can be sent  
✅ AI responses are received  
✅ Theme switching works  
✅ Theme persists on restart  
✅ Model selection works  
✅ Error handling active  

## 🔜 Coming Soon

- Dashboard functionality
- Hotkeys configuration
- Text rephrasing features
- Usage statistics
- Export/Import settings

---

**Need Help?** Check the error console or review `IMPLEMENTATION_GUIDE.md` for detailed information.

