import Foundation
import AppKit
import UserNotifications

class MenuBarManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
	private var statusItem: NSStatusItem?
	private var isMenuBarSetup = false
	
	override init() {
		super.init()
		// Defer menu bar setup to avoid Core Graphics initialization issues on older macOS versions
		requestNotificationPermissions()
		setupNotificationDelegate()
	}
	
	func setupMenuBar() {
		// Only setup once
		guard !isMenuBarSetup else { return }
		isMenuBarSetup = true
		
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		
		if let button = statusItem?.button {
			button.image = NSImage(systemSymbolName: "music.note.house", accessibilityDescription: "MP3 Player")
			button.toolTip = "MP3 Player"
		}
	}
	
	private func requestNotificationPermissions() {
		// Only request notification permissions on macOS Sequoia (15.0) and later
		// macOS Sonoma and earlier have compatibility issues with notification display
		guard #available(macOS 15.0, *) else {
			return
		}
		
		let center = UNUserNotificationCenter.current()
            // Notification with sound
//		center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Silent notification
        center.requestAuthorization(options: [.alert]) { granted, error in

			if let error = error {
				print("Error requesting notification permissions: \(error)")
			}
		}
	}
	
	private func setupNotificationDelegate() {
		// Only setup notification delegate on macOS Sequoia (15.0) and later
		guard #available(macOS 15.0, *) else {
			return
		}
		
		UNUserNotificationCenter.current().delegate = self
	}
	
	func showNotification(title: String, artist: String) {
		// Only show notifications on macOS Sequoia (15.0) and later
		// macOS Sonoma and earlier have compatibility issues with notification display
		guard #available(macOS 15.0, *) else {
			return
		}
		
		let content = UNMutableNotificationContent()
        let artistToShow = artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? NSLocalizedString("Unknown Artist", comment: "Fallback artist name") : artist
        
		// macOS Sequoia (15.0) and later - use title/subtitle structure
		content.title = title
		content.subtitle = artistToShow
//		content.body = NSLocalizedString("Now Playing", comment: "Notification body when song changes")
        content.sound = nil // Silent notification
		
            // Use a 1 second trigger for reliable delivery
            // Using a unique identifier ensures each notification is treated as new
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        	// Using floating-point timestamp as identifier could lead to precision issues or collisions
        	// in rapid succession. Alternative is to use a more robust unique identifier like UUID
//        let identifier = "now-playing-\(Date().timeIntervalSince1970)"
        let identifier = "now-playing-\(UUID().uuidString)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error {
				print("Error showing notification: \(error)")
			}
		}
	}
	
	deinit {
		if let statusItem = statusItem {
			NSStatusBar.system.removeStatusItem(statusItem)
		}
	}
	
	// MARK: - UNUserNotificationCenterDelegate
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Show notification even when app is in foreground
		// Use .list to ensure notification appears in Notification Center as well
		completionHandler([.banner, .list])
	}
}
