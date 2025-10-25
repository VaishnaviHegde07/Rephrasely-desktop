import Cocoa
import Carbon

/// Manages global hotkey registration and detection
class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var eventMonitor: Any?
    private var registeredHotkeys: [String: HotkeyConfig] = [:]
    private var pressedModifiers: NSEvent.ModifierFlags = []
    private var pressedKeys: Set<UInt16> = []
    
    // Callback when a hotkey is pressed
    var onHotkeyPressed: ((String) -> Void)?
    
    private init() {}
    
    /// Start monitoring for global hotkey events
    func startMonitoring() {
        // Monitor key down events globally
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        print("🔥 HotkeyManager: Started global monitoring")
    }
    
    /// Stop monitoring
    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        print("🔥 HotkeyManager: Stopped monitoring")
    }
    
    /// Register a hotkey for global capture
    func registerHotkey(id: String, keyCombo: String) -> Bool {
        guard let config = parseKeyCombo(keyCombo) else {
            print("❌ HotkeyManager: Failed to parse key combo: \(keyCombo)")
            return false
        }
        
        registeredHotkeys[id] = config
        print("✅ HotkeyManager: Registered hotkey '\(id)' -> \(keyCombo)")
        return true
    }
    
    /// Unregister a hotkey
    func unregisterHotkey(id: String) {
        registeredHotkeys.removeValue(forKey: id)
        print("🗑️ HotkeyManager: Unregistered hotkey '\(id)'")
    }
    
    /// Unregister all hotkeys
    func unregisterAllHotkeys() {
        registeredHotkeys.removeAll()
        print("🗑️ HotkeyManager: Unregistered all hotkeys")
    }
    
    /// Handle incoming key events
    private func handleKeyEvent(_ event: NSEvent) {
        if event.type == .flagsChanged {
            pressedModifiers = event.modifierFlags
            return
        }
        
        guard event.type == .keyDown else { return }
        
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags
        
        // Check if this matches any registered hotkey
        for (id, config) in registeredHotkeys {
            if config.matches(keyCode: keyCode, modifiers: modifiers) {
                print("🎯 HotkeyManager: Hotkey matched! ID: \(id)")
                onHotkeyPressed?(id)
                break
            }
        }
    }
    
    /// Parse key combination string (e.g., "Cmd+Shift+R") into HotkeyConfig
    private func parseKeyCombo(_ combo: String) -> HotkeyConfig? {
        let parts = combo.split(separator: "+").map { $0.trimmingCharacters(in: .whitespaces) }
        
        var modifiers: NSEvent.ModifierFlags = []
        var keyCode: UInt16?
        
        for part in parts {
            let lowercased = part.lowercased()
            
            switch lowercased {
            case "cmd", "command", "⌘":
                modifiers.insert(.command)
            case "shift", "⇧":
                modifiers.insert(.shift)
            case "alt", "option", "opt", "⌥":
                modifiers.insert(.option)
            case "ctrl", "control", "⌃":
                modifiers.insert(.control)
            case "fn":
                modifiers.insert(.function)
            default:
                // This should be the key itself
                keyCode = getKeyCode(for: lowercased)
            }
        }
        
        guard let code = keyCode else {
            return nil
        }
        
        return HotkeyConfig(keyCode: code, modifiers: modifiers)
    }
    
    /// Map key names to macOS key codes
    private func getKeyCode(for key: String) -> UInt16? {
        let keyMap: [String: UInt16] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
            "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
            "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
            "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
            "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "l": 37,
            "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
            "n": 45, "m": 46, ".": 47, "`": 50,
            "return": 36, "tab": 48, "space": 49, "delete": 51, "escape": 53,
            "f1": 122, "f2": 120, "f3": 99, "f4": 118, "f5": 96, "f6": 97,
            "f7": 98, "f8": 100, "f9": 101, "f10": 109, "f11": 103, "f12": 111
        ]
        
        return keyMap[key.lowercased()]
    }
}

/// Configuration for a single hotkey
struct HotkeyConfig {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
    
    /// Check if the given key event matches this hotkey
    func matches(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        // Compare key codes
        guard keyCode == self.keyCode else { return false }
        
        // Compare modifiers (ignore capsLock and numericPad)
        let relevantModifiers: NSEvent.ModifierFlags = [.command, .shift, .option, .control, .function]
        let eventMods = modifiers.intersection(relevantModifiers)
        let configMods = self.modifiers.intersection(relevantModifiers)
        
        return eventMods == configMods
    }
}

