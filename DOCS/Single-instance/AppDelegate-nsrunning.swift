import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
    
    // MARK: - Only one instance of the app should be allowed to run at a time
    // Launching a duplicate instance should bring the existing one
    // to the foreground and exit immediately.
    
        if let bundleID = Bundle.main.bundleIdentifier {
            let runningInstances = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
            if runningInstances.count > 1 {
                for app in runningInstances where app != NSRunningApplication.current {
                    app.activate(options: .activateIgnoringOtherApps)
                    break
                }
                NSApp.terminate(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
