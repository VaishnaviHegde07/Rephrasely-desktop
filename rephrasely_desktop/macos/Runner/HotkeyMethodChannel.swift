import FlutterMacOS
import Foundation

/// Bridges Swift hotkey system with Flutter via Method Channel
class HotkeyMethodChannel {
    private let channel: FlutterMethodChannel
    private var isProcessing = false
    
    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "com.rephrasely/hotkeys",
            binaryMessenger: messenger
        )
        
        setupMethodHandler()
        setupHotkeyListener()
        
        print("🔌 HotkeyMethodChannel: Initialized")
    }
    
    /// Setup handler for methods called from Flutter
    private func setupMethodHandler() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "registerHotkey":
                self.handleRegisterHotkey(call, result)
                
            case "unregisterHotkey":
                self.handleUnregisterHotkey(call, result)
                
            case "unregisterAllHotkeys":
                HotkeyManager.shared.unregisterAllHotkeys()
                result(true)
                
            case "pasteResult":
                self.handlePasteResult(call, result)
                
            case "saveToHistory":
                self.handleSaveToHistory(call, result)
                
            case "getHistory":
                self.handleGetHistory(result)
                
            case "clearHistory":
                HistoryManager.shared.clearHistory()
                result(true)
                
            case "deleteHistoryEntry":
                self.handleDeleteHistoryEntry(call, result)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    /// Setup listener for hotkey press events
    private func setupHotkeyListener() {
        HotkeyManager.shared.onHotkeyPressed = { [weak self] hotkeyId in
            guard let self = self else { return }
            
            // Prevent multiple simultaneous processing
            if self.isProcessing {
                print("⚠️ HotkeyMethodChannel: Already processing, ignoring hotkey")
                return
            }
            
            self.isProcessing = true
            
            print("🔥 HotkeyMethodChannel: Hotkey pressed - \(hotkeyId)")
            
            // Notify Flutter that hotkey was pressed
            self.channel.invokeMethod("onHotkeyPressed", arguments: hotkeyId)
            
            // Capture selected text
            Task {
                if let text = await ClipboardManager.shared.captureSelectedText() {
                    print("📤 HotkeyMethodChannel: Sending captured text to Flutter")
                    await MainActor.run {
                        self.channel.invokeMethod(
                            "onTextCaptured",
                            arguments: [
                                "hotkeyId": hotkeyId,
                                "text": text
                            ]
                        )
                    }
                } else {
                    print("❌ HotkeyMethodChannel: No text captured")
                    await MainActor.run {
                        self.channel.invokeMethod(
                            "onTextCaptureError",
                            arguments: "No text selected. Please select text and try again."
                        )
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    /// Handle registering a hotkey
    private func handleRegisterHotkey(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let keyCombo = args["keyCombo"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing 'id' or 'keyCombo'",
                details: nil
            ))
            return
        }
        
        let success = HotkeyManager.shared.registerHotkey(id: id, keyCombo: keyCombo)
        result(success)
    }
    
    /// Handle unregistering a hotkey
    private func handleUnregisterHotkey(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing 'id'",
                details: nil
            ))
            return
        }
        
        HotkeyManager.shared.unregisterHotkey(id: id)
        result(true)
    }
    
    /// Handle pasting transformed text
    private func handlePasteResult(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let text = args["text"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing 'text'",
                details: nil
            ))
            self.isProcessing = false
            return
        }
        
        let shouldRestore = args["restoreClipboard"] as? Bool ?? true
        
        Task {
            await ClipboardManager.shared.pasteText(text)
            
            if shouldRestore {
                ClipboardManager.shared.restoreClipboard()
            }
            
            await MainActor.run {
                result(true)
                self.isProcessing = false
            }
        }
    }
    
    /// Handle saving transformation to history
    private func handleSaveToHistory(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let hotkeyId = args["hotkeyId"] as? String,
              let hotkeyName = args["hotkeyName"] as? String,
              let originalText = args["originalText"] as? String,
              let transformedText = args["transformedText"] as? String,
              let modelName = args["modelName"] as? String,
              let actionType = args["actionType"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing required fields",
                details: nil
            ))
            return
        }
        
        HistoryManager.shared.saveTransformation(
            hotkeyId: hotkeyId,
            hotkeyName: hotkeyName,
            originalText: originalText,
            transformedText: transformedText,
            modelName: modelName,
            actionType: actionType
        )
        
        result(true)
    }
    
    /// Handle getting history
    private func handleGetHistory(_ result: @escaping FlutterResult) {
        let history = HistoryManager.shared.loadHistory()
        
        let historyData = history.map { entry -> [String: Any] in
            return [
                "id": entry.id,
                "hotkeyId": entry.hotkeyId,
                "hotkeyName": entry.hotkeyName,
                "originalText": entry.originalText,
                "transformedText": entry.transformedText,
                "modelName": entry.modelName,
                "actionType": entry.actionType,
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp)
            ]
        }
        
        result(historyData)
    }
    
    /// Handle deleting a history entry
    private func handleDeleteHistoryEntry(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Missing 'id'",
                details: nil
            ))
            return
        }
        
        HistoryManager.shared.deleteEntry(id: id)
        result(true)
    }
}

