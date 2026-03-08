import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Only one instance of the application at a time

    // Holds the lock file descriptor for the lifetime of the app.
    // The OS releases the lock automatically when the process exits.
    private var lockFileDescriptor: Int32 = -1

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Use a POSIX file lock for atomic single-instance enforcement.
        // Unlike the NSRunningApplication approach, flock() is handled by the
        // kernel and is race-condition free even when multiple instances launch
        // at the same time.
        let lockPath = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("com.perez987.MP3Player.lock")
        lockFileDescriptor = open(lockPath, O_CREAT | O_WRONLY, 0o644)
        guard lockFileDescriptor >= 0 else {
            // Could not open the lock file; proceed without single-instance enforcement.
            return
        }
        if flock(lockFileDescriptor, LOCK_EX | LOCK_NB) != 0 {
            // Another instance already holds the lock — bring it to front and quit.
            if let bundleID = Bundle.main.bundleIdentifier {
                for app in NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
                    where app != NSRunningApplication.current {
                    app.activate(options: .activateIgnoringOtherApps)
                    break
                }
            }
            NSApp.terminate(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
