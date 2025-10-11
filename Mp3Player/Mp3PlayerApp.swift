import SwiftUI

@main
struct Mp3PlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                //                .frame(minWidth: 600, minHeight: 400)
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
        }
    }
}

extension Notification.Name {
    static let openFile = Notification.Name("openFile")
    static let openDirectory = Notification.Name("openDirectory")
    static let openFileURL = Notification.Name("openFileURL")
}
