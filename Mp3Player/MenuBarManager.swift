import Foundation
import AppKit
import UserNotifications

class MenuBarManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
	private var statusItem: NSStatusItem?
	
	override init() {
		super.init()
		setupMenuBar()
		requestNotificationPermissions()
		setupNotificationDelegate()
	}
	
	private func setupMenuBar() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		
		if let button = statusItem?.button {
			button.image = NSImage(systemSymbolName: "music.note.house", accessibilityDescription: "MP3 Player")
			button.toolTip = "MP3 Player"
		}
	}
	
	private func requestNotificationPermissions() {
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
		UNUserNotificationCenter.current().delegate = self
	}
	
	func showNotification(title: String, artist: String) {
		let content = UNMutableNotificationContent()
		content.title = NSLocalizedString("Now Playing", comment: "Notification title when song changes")
        let artistToShow = artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? NSLocalizedString("Unknown Artist", comment: "Fallback artist name") : artist
        content.body = "\(title)\n\(artistToShow)"
        content.sound = nil // Silent notification
		
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
		
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
		// Show notification even when app is in foreground (silent notification)
		completionHandler([.banner])
	}
}
