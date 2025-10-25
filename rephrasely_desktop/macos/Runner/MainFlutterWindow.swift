import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Set initial window size
    let initialSize = NSSize(width: 1400, height: 900)
    self.setContentSize(initialSize)
    
    // Center the window on screen
    self.center()
    
    // Set minimum window size to prevent layout overflow
    self.minSize = NSSize(width: 1200, height: 700)
    
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
