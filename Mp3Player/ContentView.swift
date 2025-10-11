
import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var audioPlayer = AudioPlayerManager()
    @StateObject private var playlistManager = PlaylistManager()

    var body: some View {
        ZStack {
            // Background album art
            if let albumArt = audioPlayer.albumArt {
                Image(nsImage: albumArt)
                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 2)
                    .opacity(0.2)
//                    .ignoresSafeArea()
            }
            
            VStack(spacing: 20) {
                // Song Info Display
            VStack(spacing: 10) {
                ScrollingText(
					text: audioPlayer.currentTrack?.title ?? NSLocalizedString("No Song Playing", comment: "Message when no song is playing"),
                    font: .title
                )
                .frame(height: 30)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

				Text(audioPlayer.currentTrack?.artist ?? "")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(height: 80)
            .padding(.top, 20)

                // Time Display
            HStack {
                Text(audioPlayer.elapsedTime)
                    .font(.system(.body, design: .monospaced))

                Spacer()

                Text(audioPlayer.remainingTime)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.horizontal, 40)

                // Progress Bar
            Slider(
                value: Binding(
                    get: { audioPlayer.currentTime },
                    set: { audioPlayer.seek(to: $0) }
                ),
                in: 0...max(audioPlayer.duration, 0.01)
            )
            .padding(.horizontal, 40)

                // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    playlistManager.previous()
                    if let track = playlistManager.currentTrack {
                        audioPlayer.play(track: track)
                    }
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                .help(NSLocalizedString("Previous", comment: ""))
                .buttonStyle(.plain)
                .disabled(playlistManager.tracks.isEmpty)

                Button(action: {
                    if audioPlayer.isPlaying {
                        audioPlayer.togglePlayPause()
                    } else if let track = playlistManager.currentTrack {
                        if audioPlayer.currentTrack == track {
                            audioPlayer.togglePlayPause()
                        } else {
                            audioPlayer.play(track: track)
                        }
                    }
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                .help(NSLocalizedString("Pause", comment: ""))
                .buttonStyle(.plain)
                .disabled(playlistManager.tracks.isEmpty)

                Button(action: {
                    audioPlayer.stop()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title)
                }
                .help(NSLocalizedString("Play/Stop", comment: ""))
                .buttonStyle(.plain)
                .disabled(playlistManager.tracks.isEmpty)

                Button(action: {
                    playlistManager.next()
                    if let track = playlistManager.currentTrack {
                        audioPlayer.play(track: track)
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
                .help(NSLocalizedString("Next", comment: ""))
                .buttonStyle(.plain)
                .disabled(playlistManager.tracks.isEmpty)

                Button(action: {
                    playlistManager.toggleShuffle()
                }) {
                    Image(systemName: "shuffle")
                        .font(.title)
                        .foregroundColor(playlistManager.isShuffleMode ? .blue : .primary)
                }
                .help(NSLocalizedString("Shuffle", comment: ""))
                .buttonStyle(.plain)
                .disabled(playlistManager.tracks.isEmpty)
            }
            .padding(.vertical, 20)

                // Playlist info
            if !playlistManager.tracks.isEmpty {
                VStack(spacing: 4) {
                    Text("\(playlistManager.currentIndex + 1) / \(playlistManager.tracks.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)


                    if let directoryPath = playlistManager.currentDirectoryPath {
                        let localizedText = NSLocalizedString("Directory being played: ", comment: "")
                        Text(localizedText + directoryPath)
                            //                        Text(directoryPath)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 20)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            playlistManager.restoreLastTrack()
            if let track = playlistManager.currentTrack {
                audioPlayer.play(track: track)
            }
            setupNotifications()
        }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .openFile,
            object: nil,
            queue: .main
        ) { _ in
            openFilePicker()
        }

        NotificationCenter.default.addObserver(
            forName: .openDirectory,
            object: nil,
            queue: .main
        ) { _ in
            openDirectoryPicker()
        }

        NotificationCenter.default.addObserver(
            forName: .openFileURL,
            object: nil,
            queue: .main
        ) { notification in
            if let url = notification.object as? URL {
                playlistManager.loadFile(url)
                if let track = playlistManager.currentTrack {
                    audioPlayer.play(track: track)
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .trackFinished,
            object: nil,
            queue: .main
        ) { _ in
            playlistManager.next()
            if let track = playlistManager.currentTrack {
                audioPlayer.play(track: track)
            }
        }
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.mp3]

        if panel.runModal() == .OK, let url = panel.url {
            playlistManager.loadFile(url)
            if let track = playlistManager.currentTrack {
                audioPlayer.play(track: track)
            }
        }
    }

    private func openDirectoryPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let url = panel.url {
            playlistManager.loadDirectory(url)
            if let track = playlistManager.currentTrack {
                audioPlayer.play(track: track)
            }
        }
    }
}

#Preview {
    ContentView()
}

