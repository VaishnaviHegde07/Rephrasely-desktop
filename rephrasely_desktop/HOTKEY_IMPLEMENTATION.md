# Global Hotkey System Implementation

## ✅ Completed Implementation

### Phase 1: Native macOS Layer (Swift)
Created the following Swift files in `macos/Runner/`:

1. **HotkeyManager.swift** - Global hotkey capture and registration
   - Uses `NSEvent.addGlobalMonitorForEvents` for system-wide monitoring
   - Supports Cmd, Shift, Alt, Ctrl, Fn modifiers
   - Maps key combinations like "Cmd+Shift+R" to hotkey IDs

2. **ClipboardManager.swift** - Text capture and paste automation
   - Backs up clipboard before operations
   - Simulates Cmd+C to copy selected text
   - Simulates Cmd+V to paste transformed text
   - Restores original clipboard after operation

3. **HistoryManager.swift** - Persistent transformation history
   - Stores up to 1000 transformations
   - Date-wise organization
   - JSON-based storage using UserDefaults

4. **HotkeyMethodChannel.swift** - Flutter ↔ Swift bridge
   - Method channel: `com.rephrasely/hotkeys`
   - Handles hotkey registration/unregistration
   - Captures text and sends to Flutter
   - Manages paste operations
   - Saves/loads history

5. **AppDelegate.swift** - Application lifecycle integration
   - Initializes hotkey system on launch
   - Requests Accessibility permissions
   - Cleans up on termination

6. **Info.plist** - Added required permissions
   - `NSAppleEventsUsageDescription` - For keyboard simulation
   - `NSAccessibilityUsageDescription` - For global hotkey capture

### Phase 2: Flutter/Dart Layer
Created the following Dart services and providers:

1. **HotkeyService** (`lib/services/hotkey_service.dart`)
   - Communicates with native Swift layer
   - Registers/unregisters hotkeys
   - Handles text capture callbacks
   - Manages history operations

2. **TextProcessingService** (`lib/services/text_processing_service.dart`)
   - Processes text using OpenRouter AI
   - Builds prompts based on hotkey configuration
   - Supports different action types (rephrase, fix grammar, summarize, expand, custom)
   - Handles style variations (professional, casual, concise, detailed)

3. **HotkeyCoordinatorService** (`lib/services/hotkey_coordinator_service.dart`)
   - Orchestrates complete flow: capture → AI process → paste
   - Handles errors and edge cases
   - Manages concurrent processing prevention
   - Saves transformations to history

4. **TransformationHistory** (`lib/models/transformation_history.dart`)
   - Data model for history entries
   - Date formatting and grouping
   - Relative time display ("5 minutes ago")

5. **HistoryProvider** (`lib/providers/history_provider.dart`)
   - State management for transformation history
   - Date-wise grouping
   - Search and filtering
   - Statistics calculation

6. **Updated HotkeyProvider** (`lib/providers/hotkey_provider.dart`)
   - Integrated with HotkeyService
   - Auto-syncs hotkeys with native system
   - Registers/unregisters on add/update/delete/toggle

### Phase 3: Integration
- Updated `main.dart` to initialize all services and providers
- Updated `MainScreen` to create HotkeyCoordinatorService
- All providers wired together correctly

## 🔧 Next Steps to Complete

### 1. Add Swift Files to Xcode Project (MANUAL STEP REQUIRED)
The Xcode workspace has been opened. You need to:

1. In Xcode, right-click on the "Runner" folder
2. Select "Add Files to 'Runner'..."
3. Navigate to `macos/Runner/` and select these files:
   - HotkeyManager.swift
   - ClipboardManager.swift
   - HistoryManager.swift
   - HotkeyMethodChannel.swift
4. Make sure "Copy items if needed" is **unchecked**
5. Make sure "Runner" target is **checked**
6. Click "Add"

Alternatively, the files are already in the correct location, so you can build from command line and Xcode should pick them up automatically.

### 2. Grant Accessibility Permissions
When you first run the app:
1. macOS will prompt for Accessibility permissions
2. Go to **System Settings** → **Privacy & Security** → **Accessibility**
3. Add and enable Rephrasely Desktop

### 3. Test the Complete Flow
1. Build and run the app
2. Configure an API key in Settings
3. Create a hotkey (e.g., "Cmd+Shift+R" for rephrase)
4. Activate the hotkey
5. In any app, select some text
6. Press the hotkey
7. The text should be transformed and replaced

## 📋 How It Works

### Complete Flow Diagram
```
User selects text in any app (e.g., Notes, Browser)
         ↓
User presses hotkey (e.g., Cmd+Shift+R)
         ↓
HotkeyManager (Swift) detects key combination
         ↓
ClipboardManager backs up clipboard
         ↓
ClipboardManager simulates Cmd+C to copy selected text
         ↓
Text sent to Flutter via Method Channel
         ↓
HotkeyCoordinatorService receives text
         ↓
TextProcessingService builds AI prompt
         ↓
OpenRouter API processes text
         ↓
Transformed text returned
         ↓
HistoryManager saves transformation
         ↓
ClipboardManager pastes result (Cmd+V)
         ↓
Original clipboard restored (optional)
         ↓
User sees transformed text in their app!
```

### Key Features Implemented
- ✅ Global hotkey capture (works in any app)
- ✅ Clipboard-based text capture
- ✅ AI-powered text transformation
- ✅ Automatic paste-back
- ✅ Clipboard restoration
- ✅ Transformation history
- ✅ Multiple action types
- ✅ Style variations
- ✅ Custom prompts
- ✅ Hotkey enable/disable
- ✅ Configurable behaviors (auto-replace, copy-only, confirmation)

## 🎯 Configuration Options

Each hotkey supports:
- **Action Type**: Rephrase, Fix Grammar, Summarize, Expand, Custom
- **Style**: Professional, Casual, Concise, Detailed, Custom
- **AI Model**: Any OpenRouter model
- **Behaviors**:
  - `isActive` - Enable/disable hotkey
  - `autoReplace` - Automatically paste result
  - `copyToClipboard` - Copy result to clipboard
  - `showConfirmationPopup` - Show preview before replacing (TODO)
  - Custom prompt for advanced use cases

## 🔒 Privacy & Security
- All processing happens locally and via OpenRouter API
- No data is logged or sent elsewhere
- Clipboard backup ensures user data safety
- History stored locally using macOS UserDefaults
- Maximum 1000 history entries (FIFO)

## 🐛 Known Limitations
1. Confirmation popup not yet implemented (auto-paste only)
2. No visual feedback during processing (overlay planned)
3. Windows/Linux support not yet implemented
4. History UI screen not yet created

## 📱 Future Enhancements
- [ ] Processing overlay with progress indicator
- [ ] Confirmation dialog with before/after preview
- [ ] History UI screen with date-wise sorting
- [ ] System tray integration
- [ ] Auto-start on boot
- [ ] Sensitive app detection (password managers)
- [ ] Rate limit handling
- [ ] Undo last transformation
- [ ] Windows & Linux support

## 🔨 Technical Notes

### Required Permissions
- **Accessibility**: Required for global hotkey monitoring and keyboard simulation
- **Apple Events**: Required for Cmd+C/Cmd+V simulation

### Platform-Specific Details
- Uses Carbon API keycodes for cross-compatibility
- `CGEvent` for keyboard event simulation
- `NSPasteboard` for clipboard operations
- `NSEvent.addGlobalMonitorForEvents` for hotkey capture
- Method Channel pattern for Flutter ↔ Swift communication

### Error Handling
- Duplicate hotkey detection
- Empty text validation
- API failure graceful degradation
- Clipboard restore on errors
- Concurrent processing prevention

---

**Status**: Implementation complete, ready for testing after adding Swift files to Xcode project.

