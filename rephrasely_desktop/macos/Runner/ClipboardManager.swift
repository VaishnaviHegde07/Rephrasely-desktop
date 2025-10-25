import Cocoa
import Carbon

/// Manages clipboard operations and text capture/paste simulation
class ClipboardManager {
    static let shared = ClipboardManager()
    
    private let pasteboard = NSPasteboard.general
    private var clipboardBackup: String?
    
    private init() {}
    
    /// Backup current clipboard content
    func backupClipboard() {
        clipboardBackup = pasteboard.string(forType: .string)
        if clipboardBackup != nil {
            print("📋 ClipboardManager: Backed up clipboard")
        }
    }
    
    /// Capture selected text by simulating Cmd+C
    /// Returns the captured text or nil if nothing was selected
    func captureSelectedText() async -> String? {
        // Backup existing clipboard
        backupClipboard()
        
        // Clear clipboard to detect new content
        let changeCount = pasteboard.changeCount
        
        // Simulate Cmd+C
        print("⌨️  ClipboardManager: Simulating Cmd+C")
        simulateKeyPress(keyCode: 8, modifiers: .maskCommand) // 'C' key
        
        // Wait for clipboard to update (150ms)
        try? await Task.sleep(nanoseconds: 150_000_000)
        
        // Check if clipboard content changed
        if pasteboard.changeCount > changeCount {
            let capturedText = pasteboard.string(forType: .string)
            if let text = capturedText, !text.isEmpty {
                print("✅ ClipboardManager: Captured \(text.count) characters")
                return text
            }
        }
        
        print("⚠️ ClipboardManager: No text captured")
        return nil
    }
    
    /// Paste text by writing to clipboard and simulating Cmd+V
    func pasteText(_ text: String) async {
        print("📝 ClipboardManager: Pasting \(text.count) characters")
        
        // Write to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Small delay to ensure clipboard is updated
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Simulate Cmd+V
        print("⌨️  ClipboardManager: Simulating Cmd+V")
        simulateKeyPress(keyCode: 9, modifiers: .maskCommand) // 'V' key
        
        // Wait for paste to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        print("✅ ClipboardManager: Paste complete")
    }
    
    /// Restore previously backed up clipboard content
    func restoreClipboard() {
        if let backup = clipboardBackup {
            pasteboard.clearContents()
            pasteboard.setString(backup, forType: .string)
            print("♻️  ClipboardManager: Restored clipboard")
        }
        clipboardBackup = nil
    }
    
    /// Simulate a key press with modifiers
    private func simulateKeyPress(keyCode: CGKeyCode, modifiers: CGEventFlags) {
        // Create key down event
        guard let eventDown = CGEvent(
            keyboardEventSource: nil,
            virtualKey: keyCode,
            keyDown: true
        ) else {
            print("❌ ClipboardManager: Failed to create key down event")
            return
        }
        eventDown.flags = modifiers
        eventDown.post(tap: .cghidEventTap)
        
        // Small delay between down and up
        usleep(10000) // 10ms
        
        // Create key up event
        guard let eventUp = CGEvent(
            keyboardEventSource: nil,
            virtualKey: keyCode,
            keyDown: false
        ) else {
            print("❌ ClipboardManager: Failed to create key up event")
            return
        }
        eventUp.post(tap: .cghidEventTap)
    }
}

