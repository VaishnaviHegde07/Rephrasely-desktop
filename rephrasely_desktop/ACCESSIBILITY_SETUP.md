# macOS Accessibility Setup for Rephrasely

## Why Accessibility Permissions Are Required

Rephrasely needs two critical macOS permissions to function:

1. **Accessibility Access**: To detect global hotkeys and simulate keyboard events (Cmd+C, Cmd+V)
2. **Automation/Apple Events**: To control keyboard and clipboard operations

## Setup Instructions

### Step 1: Enable Accessibility Access

1. Open **System Settings** (or System Preferences on older macOS)
2. Navigate to **Privacy & Security** → **Accessibility**
3. Click the **lock icon** at the bottom left and enter your password
4. Look for **rephrasely_desktop** in the list
5. If it's not there, click the **"+"** button and add the app from:
   - `/Users/YOUR_USERNAME/Desktop/Rephrasely-desktop/rephrasely_desktop/build/macos/Build/Products/Debug/rephrasely_desktop.app`
6. **Enable the checkbox** next to rephrasely_desktop

### Step 2: Verify Permissions

After enabling, the app should show:
```
✅ Accessibility permissions: Granted
```

If you see:
```
⚠️  Accessibility permissions: Not granted - will prompt user
```

You need to:
1. Quit the app completely
2. Reopen System Settings → Privacy & Security → Accessibility
3. **Remove** rephrasely_desktop from the list
4. Relaunch the app - it should now prompt you for permission

### Step 3: Test Hotkey Capture

1. Open any text editor or application
2. Select some text
3. Press your configured hotkey (e.g., Cmd+Shift+V)
4. Watch the terminal output for:
   ```
   🔥 HotkeyManager: Hotkey matched! ID: 1
   📋 ClipboardManager: Backed up clipboard
   ⌨️  ClipboardManager: Simulating Cmd+C
   ✅ ClipboardManager: Captured X characters
   ```

### Common Issues

**Issue**: "No text captured"
- **Solution**: Make sure text is actually selected before pressing the hotkey

**Issue**: Hotkey doesn't trigger at all
- **Solution**: 
  1. Check that the hotkey is enabled (green toggle in the Hotkeys screen)
  2. Make sure the app has Accessibility permissions
  3. Try a different key combination to avoid conflicts

**Issue**: Text is captured but not pasted back
- **Solution**: Check terminal logs for errors in the AI processing step

### Terminal Logging

When you press a hotkey, you should see this flow in the terminal:

1. **Hotkey Detection**:
   ```
   🎯 HotkeyManager: Hotkey matched! ID: 1
   🔥 HotkeyMethodChannel: Hotkey pressed - 1
   ```

2. **Text Capture**:
   ```
   📋 ClipboardManager: Backed up clipboard
   ⌨️  ClipboardManager: Simulating Cmd+C
   ✅ ClipboardManager: Captured 48 characters
   ```

3. **AI Processing**:
   ```
   📥 HotkeyService: Text captured - 48 chars
   🎯 HotkeyCoordinator: Processing hotkey 1 with 48 chars
   🤖 HotkeyCoordinator: Sending to AI...
   ```

4. **Result Pasting**:
   ```
   ✅ HotkeyCoordinator: Received transformed text (52 chars)
   📝 ClipboardManager: Pasting 52 characters
   ⌨️  ClipboardManager: Simulating Cmd+V
   ✅ ClipboardManager: Paste complete
   ```

If any step is missing, check the terminal for error messages.

