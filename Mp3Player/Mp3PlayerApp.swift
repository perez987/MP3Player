import SwiftUI

@main
struct Mp3PlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 350, idealHeight: 350, maxHeight: 350)
                .onOpenURL { url in
                    	// Handle MP3 files opened from Finder
                    if url.pathExtension.lowercased() == "mp3" {
                        NotificationCenter.default.post(name: .openFileURL, object: url)
                    }
                }
        }

            // window resizability derived from the window’s content
            // macOS 13 Ventura or newer
        .windowResizability(.contentSize)

            // File > Open menus
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(NSLocalizedString("Open MP3 File...", comment: "Menu item to open a single MP3 file")) {
                    NotificationCenter.default.post(name: .openFile, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)

                Button(NSLocalizedString("Open Directory...", comment: "Menu item to open a directory of MP3 files")) {
                    NotificationCenter.default.post(name: .openDirectory, object: nil)
                }
                .keyboardShortcut("d", modifiers: .command)
                
            }
            
                // Play menus
            CommandMenu(NSLocalizedString("Play", comment: "Play menu")) {
                Button(NSLocalizedString("Previous", comment: "Menu item to play previous track")) {
                    NotificationCenter.default.post(name: .playPrevious, object: nil)
                }
                .keyboardShortcut("a", modifiers: .control)
                
                Button(NSLocalizedString("Play/Pause", comment: "Menu item to toggle play/pause")) {
                    NotificationCenter.default.post(name: .playTogglePlayPause, object: nil)
                }
                .keyboardShortcut("p", modifiers: .control)
                
                Button(NSLocalizedString("Stop", comment: "Menu item to stop playback")) {
                    NotificationCenter.default.post(name: .playStop, object: nil)
                }
                .keyboardShortcut("s", modifiers: .control)
                
                Button(NSLocalizedString("Next", comment: "Menu item to play next track")) {
                    NotificationCenter.default.post(name: .playNext, object: nil)
                }
                .keyboardShortcut("n", modifiers: .control)
                
                Button(NSLocalizedString("Shuffle", comment: "Menu item to toggle shuffle mode")) {
                    NotificationCenter.default.post(name: .playToggleShuffle, object: nil)
                }
                .keyboardShortcut("h", modifiers: .control)
            }
        }
    }
}

    // Commands notification
extension Notification.Name {
    static let openFile = Notification.Name("openFile")
    static let openDirectory = Notification.Name("openDirectory")
    static let openFileURL = Notification.Name("openFileURL")
    static let playPrevious = Notification.Name("playPrevious")
    static let playTogglePlayPause = Notification.Name("playTogglePlayPause")
    static let playStop = Notification.Name("playStop")
    static let playNext = Notification.Name("playNext")
    static let playToggleShuffle = Notification.Name("playToggleShuffle")
}
