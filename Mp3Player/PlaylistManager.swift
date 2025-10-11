import Foundation
import Combine

class PlaylistManager: ObservableObject {
	@Published var tracks: [Track] = []
	@Published var currentIndex: Int = 0
	@Published var isShuffleMode: Bool = false
	@Published var currentDirectoryPath: String?

	private var shuffledIndices: [Int] = []
	private var currentShufflePosition: Int = 0
	private var currentDirectorySecurityScopedURL: URL?

	var currentTrack: Track? {
		guard !tracks.isEmpty, currentIndex < tracks.count else { return nil }
		return tracks[currentIndex]
	}

	func loadFile(_ url: URL) {
			// Stop accessing previous directory if any
		if let previousDirectoryURL = currentDirectorySecurityScopedURL {
			previousDirectoryURL.stopAccessingSecurityScopedResource()
			currentDirectorySecurityScopedURL = nil
		}

		tracks = [Track(url: url)]
		currentIndex = 0
		currentDirectoryPath = nil
			// Clear directory bookmark since we're loading a single file
		UserDefaults.standard.removeObject(forKey: "lastPlayedDirectoryBookmark")
	}

	func loadDirectory(_ url: URL, alreadyAccessing: Bool = false) {
			// Stop accessing previous directory if any (but not if it's the same URL we're loading)
		if let previousDirectoryURL = currentDirectorySecurityScopedURL, previousDirectoryURL != url {
			previousDirectoryURL.stopAccessingSecurityScopedResource()
			currentDirectorySecurityScopedURL = nil
		}

			// If we're not already accessing this URL, start accessing it
			// When called from user action (picker), we need to start accessing
			// When called from restoreLastTrack, it's already being accessed
		if !alreadyAccessing {
			if url.startAccessingSecurityScopedResource() {
				currentDirectorySecurityScopedURL = url
			}
		} else {
				// Only set if not already set (to avoid overwriting)
			if currentDirectorySecurityScopedURL == nil {
				currentDirectorySecurityScopedURL = url
			}
		}

		let fileManager = FileManager.default
		guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) else {
			return
		}

		var mp3Files: [URL] = []
		for case let fileURL as URL in enumerator {
			if fileURL.pathExtension.lowercased() == "mp3" {
				mp3Files.append(fileURL)
			}
		}

		tracks = mp3Files.sorted { $0.lastPathComponent < $1.lastPathComponent }.map { Track(url: $0) }
		currentIndex = 0

			// Store the directory path without "file://" prefix
		currentDirectoryPath = url.path

			// Save directory bookmark for restoration
		saveDirectoryBookmark(for: url)

			// Enable shuffle mode by default when loading a directory
		if !tracks.isEmpty {
			isShuffleMode = true
			shuffledIndices = Array(0..<tracks.count).shuffled()
			if let position = shuffledIndices.firstIndex(of: currentIndex) {
				currentShufflePosition = position
			}
		}
	}


	func next() {
		guard !tracks.isEmpty else { return }

		if isShuffleMode {
			currentShufflePosition += 1
			if currentShufflePosition >= shuffledIndices.count {
				currentShufflePosition = 0
			}
			currentIndex = shuffledIndices[currentShufflePosition]
		} else {
			currentIndex = (currentIndex + 1) % tracks.count
		}
	}

	func previous() {
		guard !tracks.isEmpty else { return }

		if isShuffleMode {
			currentShufflePosition -= 1
			if currentShufflePosition < 0 {
				currentShufflePosition = shuffledIndices.count - 1
			}
			currentIndex = shuffledIndices[currentShufflePosition]
		} else {
			currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
		}
	}

	func toggleShuffle() {
		isShuffleMode.toggle()

		if isShuffleMode {
				// Create shuffled indices
			shuffledIndices = Array(0..<tracks.count).shuffled()
				// Find current track in shuffled list
			if let position = shuffledIndices.firstIndex(of: currentIndex) {
				currentShufflePosition = position
			}
		}
	}

	private func saveDirectoryBookmark(for url: URL) {
		do {
			let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
			UserDefaults.standard.set(bookmarkData, forKey: "lastPlayedDirectoryBookmark")
		} catch {
			print("Error creating directory bookmark: \(error)")
		}
	}

	func restoreLastTrack() {
			// Try to restore directory first if one was previously loaded
		if let directoryBookmark = UserDefaults.standard.data(forKey: "lastPlayedDirectoryBookmark") {
			do {
				var isStale = false
				let directoryURL = try URL(resolvingBookmarkData: directoryBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

					// Check if directory exists
				var isDirectory: ObjCBool = false
				if FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
						// Access the directory
					guard directoryURL.startAccessingSecurityScopedResource() else {
						print("Failed to access directory security-scoped resource")
							// Fall back to single file restoration
						restoreLastTrackFromFile()
						return
					}

						// Load the directory (pass true since we're already accessing it)
						// This will set currentDirectorySecurityScopedURL
					loadDirectory(directoryURL, alreadyAccessing: true)

						// DON'T stop accessing - we need to keep the directory accessed
						// so that child file URLs can be played. The directory will be
						// stopped when loading a new directory/file or when the manager is deallocated

						// Try to restore the specific track that was playing
					if let lastTrackPath = UserDefaults.standard.string(forKey: "lastPlayedTrack") {
							// Find the track in the loaded directory
						if let trackIndex = tracks.firstIndex(where: { $0.url.path == lastTrackPath }) {
							currentIndex = trackIndex
								// Update shuffle position if in shuffle mode
							if isShuffleMode, let position = shuffledIndices.firstIndex(of: currentIndex) {
								currentShufflePosition = position
							}
						}
					}

					if isStale {
						print("Directory bookmark is stale, will be refreshed")
					}

					return
				} else {
					print("Last played directory no longer exists at path: \(directoryURL.path)")
				}
			} catch {
				print("Error resolving directory bookmark: \(error)")
			}
		}

			// Fall back to single file restoration
		restoreLastTrackFromFile()
	}

	private func restoreLastTrackFromFile() {
			// Try to restore from security-scoped bookmark
		if let bookmarkData = UserDefaults.standard.data(forKey: "lastPlayedTrackBookmark") {
			do {
				var isStale = false
				let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

					// Check if file exists
				if FileManager.default.fileExists(atPath: url.path) {
						// Start accessing the security-scoped resource before creating the Track
						// so that Track initializer can load metadata properly
					guard url.startAccessingSecurityScopedResource() else {
						print("Failed to access security-scoped resource")
						return
					}

						// Create the track while we have access
					loadFile(url)

						// Stop accessing now - AudioPlayerManager will start again when playing
					url.stopAccessingSecurityScopedResource()
				} else {
					print("Last played file no longer exists at path: \(url.path)")
				}

					// If bookmark is stale, it will be recreated when the track is played
				if isStale {
					print("Bookmark is stale, will be refreshed on next play")
				}
			} catch {
				print("Error resolving bookmark: \(error)")
					// Fallback: try the old method (will likely fail but worth trying)
				restoreLastTrackFallback()
			}
		} else {
				// Fallback to old method if no bookmark exists
			restoreLastTrackFallback()
		}
	}

	private func restoreLastTrackFallback() {
		if let lastPath = UserDefaults.standard.string(forKey: "lastPlayedTrack") {
			let url = URL(fileURLWithPath: lastPath)
			if FileManager.default.fileExists(atPath: url.path) {
				loadFile(url)
			}
		}
	}

	deinit {
			// Stop accessing security-scoped directory resource when deallocating
		if let url = currentDirectorySecurityScopedURL {
			url.stopAccessingSecurityScopedResource()
		}
	}
}
