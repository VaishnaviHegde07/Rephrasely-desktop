import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var hotkeyChannel: HotkeyMethodChannel?
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Initialize hotkey system
    hotkeyChannel = HotkeyMethodChannel(messenger: controller.engine.binaryMessenger)
    HotkeyManager.shared.startMonitoring()
    
    // Request Accessibility permissions (required for global hotkeys and clipboard simulation)
    requestAccessibilityPermissions()
    
    print("🚀 Rephrasely: Application launched")
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationWillTerminate(_ notification: Notification) {
    // Cleanup hotkey monitoring
    HotkeyManager.shared.stopMonitoring()
    print("👋 Rephrasely: Application terminated")
  }
  
  /// Request Accessibility permissions for global hotkey monitoring
  private func requestAccessibilityPermissions() {
    let options: NSDictionary = [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
    ]
    let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
    
    if accessibilityEnabled {
      print("✅ Accessibility permissions: Granted")
    } else {
      print("⚠️  Accessibility permissions: Not granted - will prompt user")
    }
  }
}
