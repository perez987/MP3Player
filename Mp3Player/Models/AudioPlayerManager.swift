import Foundation
import AVFoundation
import Combine
import AppKit

class AudioPlayerManager: NSObject, ObservableObject {
	@Published var isPlaying = false
	@Published var currentTime: TimeInterval = 0
	@Published var duration: TimeInterval = 0
	@Published var currentTrack: Track?
	@Published var albumArt: NSImage?

	private var player: AVAudioPlayer?
	private var timer: Timer?
	private var currentSecurityScopedURL: URL?

	override init() {
		super.init()
	}

	func play(track: Track, isFromDirectory: Bool = false) {
			// Stop accessing previous security-scoped resource if any
		if let previousURL = currentSecurityScopedURL {
			previousURL.stopAccessingSecurityScopedResource()
			currentSecurityScopedURL = nil
		}

		do {
			let url = track.url

				// Try to access as security-scoped resource
				// This is safe to call even if it's not security-scoped
			if url.startAccessingSecurityScopedResource() {
				currentSecurityScopedURL = url
			}

			player = try AVAudioPlayer(contentsOf: url)
			player?.delegate = self

				// Prepare to play on a background queue to avoid blocking the main thread
			let preparePlayer = player

				// Load metadata in the background if not already loaded
				// This happens when tracks are loaded from a directory without metadata
			var trackWithMetadata = track
			if !track.metadataLoaded {
					// Metadata not loaded yet, load it now (one track at a time, no rate limiting)
				trackWithMetadata = Track(url: url, loadMetadata: true)
			}

			DispatchQueue.global(qos: .background).async { [weak self] in
				preparePlayer?.prepareToPlay()

				DispatchQueue.main.async {
					guard let self = self, self.player === preparePlayer else { return }

					self.currentTrack = trackWithMetadata
					self.albumArt = trackWithMetadata.albumArt
					self.duration = self.player?.duration ?? 0

					self.player?.play()
					self.isPlaying = true
					self.startTimer()
					
						// Post notification for track change
					NotificationCenter.default.post(
						name: .trackChanged,
						object: nil,
						userInfo: [
							"track": trackWithMetadata,
							"title": trackWithMetadata.title,
							"artist": trackWithMetadata.artist
						]
					)
				}
			}

				// Save security-scoped bookmark to UserDefaults
			saveBookmark(for: url, isFromDirectory: isFromDirectory)

		} catch {
			print("Error playing track: \(error)")
				// If we failed to play, stop accessing the resource
			if let url = currentSecurityScopedURL {
				url.stopAccessingSecurityScopedResource()
				currentSecurityScopedURL = nil
			}
		}
	}

	private func saveBookmark(for url: URL, isFromDirectory: Bool) {
			// Always save the file path for display and restoration purposes
		UserDefaults.standard.set(url.path, forKey: "lastPlayedTrack")
		
			// Only create bookmarks for standalone files, not files from directories
			// Files in directories inherit security scope from the parent directory
			// and attempting to create bookmarks for them causes errors
		if !isFromDirectory {
			do {
				let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
				UserDefaults.standard.set(bookmarkData, forKey: "lastPlayedTrackBookmark")
			} catch {
				print("Error creating bookmark: \(error)")
			}
		} else {
				// Clear any previous standalone file bookmark when playing from directory
			UserDefaults.standard.removeObject(forKey: "lastPlayedTrackBookmark")
		}
	}

	func togglePlayPause() {
		guard let player = player else { return }

		if player.isPlaying {
			player.pause()
			isPlaying = false
			stopTimer()
		} else {
			player.play()
			isPlaying = true
			startTimer()
		}
	}

	func stop() {
		player?.stop()
		player?.currentTime = 0
		currentTime = 0
		isPlaying = false
		stopTimer()
	}

	func seek(to time: TimeInterval) {
		player?.currentTime = time
		currentTime = time
	}

	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			guard let self = self, let player = self.player else { return }
			self.currentTime = player.currentTime
		}
	}

	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

	var elapsedTime: String {
		return formatTime(currentTime)
	}

	var remainingTime: String {
		let remaining = duration - currentTime
		return "-\(formatTime(remaining))"
	}

	private func formatTime(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}

	deinit {
		stopTimer()
			// Stop accessing security-scoped resource when deallocating
		if let url = currentSecurityScopedURL {
			url.stopAccessingSecurityScopedResource()
		}
	}
}

extension AudioPlayerManager: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if flag {
			isPlaying = false
			stopTimer()
			NotificationCenter.default.post(name: .trackFinished, object: nil)
		}
	}
}

extension Notification.Name {
	static let trackFinished = Notification.Name("trackFinished")
	static let trackChanged = Notification.Name("trackChanged")
}
