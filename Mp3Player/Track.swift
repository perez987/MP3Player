import Foundation
import AVFoundation
import AppKit

struct Track: Identifiable, Equatable {
	let id = UUID()
	let url: URL
	var title: String
	var artist: String
	var albumArt: NSImage?
	var metadataLoaded: Bool = false

	init(url: URL, loadMetadata: Bool = true) {
		self.url = url

			// Set default values
		let defaultTitle = url.deletingPathExtension().lastPathComponent
		let defaultArtist = NSLocalizedString("Unknown Artist", comment: "Default artist name when metadata is missing")

		self.title = defaultTitle
		self.artist = defaultArtist
		self.albumArt = nil
		self.metadataLoaded = false

			// Only load metadata if requested (avoid loading for all tracks at once)
		if loadMetadata {
				// Load metadata synchronously but in a more controlled way
			let asset = AVAsset(url: url)
			let semaphore = DispatchSemaphore(value: 0)

			var loadedTitle: String?
			var loadedArtist: String?
			var loadedAlbumArt: NSImage?

			Task {
				do {
					let formats = try await asset.load(.availableMetadataFormats)

					for format in formats {
						let metadata = try await asset.loadMetadata(for: format)

						for item in metadata {
							if let commonKey = item.commonKey {
								if commonKey == .commonKeyTitle {
									if let value = try? await item.load(.stringValue) {
										loadedTitle = value
									}
								} else if commonKey == .commonKeyArtist {
									if let value = try? await item.load(.stringValue) {
										loadedArtist = value
									}
								} else if commonKey == .commonKeyArtwork {
									if let value = try? await item.load(.dataValue) {
										loadedAlbumArt = NSImage(data: value)
									}
								}
							}
						}
					}
				} catch {
						// Metadata loading failed. This can happen if the file is corrupt, unsupported, or missing metadata
						// In debug builds, log the error for easier debugging
#if DEBUG
					print("Track metadata loading error for \(url.lastPathComponent): \(error)")
#endif
						// In release builds, silently fail and keep default values
				}
				semaphore.signal()
			}

				// Wait for metadata to load
			semaphore.wait()

			self.title = loadedTitle ?? defaultTitle
			self.artist = loadedArtist ?? defaultArtist
			self.albumArt = loadedAlbumArt
			self.metadataLoaded = true
		}
	}

	static func == (lhs: Track, rhs: Track) -> Bool {
		lhs.id == rhs.id
	}
}
