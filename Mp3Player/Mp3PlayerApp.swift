import SwiftUI

@main
struct Mp3PlayerApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(menuBarManager)
                .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 350, idealHeight: 350, maxHeight: 350)
                .onOpenURL { url in
                    	// Handle MP3 and M4A files opened from Finder
                    let ext = url.pathExtension.lowercased()
                    if ext == "mp3" || ext == "m4a" {
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
                Button {
                    NotificationCenter.default.post(name: .openFile, object: nil)
                } label: {
                    Label(NSLocalizedString("Open Audio File...", comment: "Menu item to open a single audio file"), systemImage: "doc.badge.plus")
                }
                .keyboardShortcut("o", modifiers: .command)
                .labelStyle(.titleAndIcon)

                Button {
                    NotificationCenter.default.post(name: .openDirectory, object: nil)
                } label: {
                    Label(NSLocalizedString("Open Directory...", comment: "Menu item to open a directory of audio files"), systemImage: "folder.badge.plus")
                }
                .keyboardShortcut("d", modifiers: .command)
                .labelStyle(.titleAndIcon)
                
            }
        }
        
            // Play menus
        .commands {
            CommandMenu(NSLocalizedString("Play", comment: "Play menu")) {
                Button {
                    NotificationCenter.default.post(name: .playPrevious, object: nil)
                } label: {
                    Label(NSLocalizedString("Previous", comment: "Menu item to play previous track"), systemImage: "backward.circle")
                }
                .keyboardShortcut("a", modifiers: .control)
                .labelStyle(.titleAndIcon)
                
                Button {
                    NotificationCenter.default.post(name: .playTogglePlayPause, object: nil)
                } label: {
                    Label(NSLocalizedString("Play/Pause", comment: "Menu item to toggle play/pause"), systemImage: "playpause.circle")
                }
                .keyboardShortcut("p", modifiers: .control)
                .labelStyle(.titleAndIcon)
                
                Button {
                    NotificationCenter.default.post(name: .playStop, object: nil)
                } label: {
                    Label(NSLocalizedString("Stop", comment: "Menu item to stop playback"), systemImage: "stop.circle")
                }
                .keyboardShortcut("s", modifiers: .control)
                .labelStyle(.titleAndIcon)
                
                Button {
                    NotificationCenter.default.post(name: .playNext, object: nil)
                } label: {
                    Label(NSLocalizedString("Next", comment: "Menu item to play next track"), systemImage: "forward.circle")
                }
                .keyboardShortcut("n", modifiers: .control)
                .labelStyle(.titleAndIcon)
                
                Button {
                    NotificationCenter.default.post(name: .playToggleShuffle, object: nil)
                } label: {
                    Label(NSLocalizedString("Shuffle", comment: "Menu item to toggle shuffle mode"), systemImage: "shuffle.circle")
                }
                .keyboardShortcut("h", modifiers: .control)
                .labelStyle(.titleAndIcon)
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
