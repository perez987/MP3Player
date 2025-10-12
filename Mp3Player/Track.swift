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

            // Use a structure to hold results from async operation
            struct MetadataResult {
                let title: String?
                let artist: String?
                let albumArt: NSImage?
            }
            
            // Use a class wrapper to safely share mutable state across concurrency contexts
            final class MetadataResultBox {
                var result: MetadataResult
                let lock = NSLock()
                
                init(result: MetadataResult) {
                    self.result = result
                }
                
                func setResult(_ newResult: MetadataResult) {
                    lock.lock()
                    defer { lock.unlock() }
                    result = newResult
                }
                
                func getResult() -> MetadataResult {
                    lock.lock()
                    defer { lock.unlock() }
                    return result
                }
            }
            
            let resultBox = MetadataResultBox(result: MetadataResult(title: nil, artist: nil, albumArt: nil))

            Task.detached {
                var loadedTitle: String?
                var loadedArtist: String?
                var loadedAlbumArt: NSImage?
                
                do {
                    let formats = try await asset.load(.availableMetadataFormats)

                    for format in formats {
                        let metadata = try await asset.loadMetadata(for: format)

                        for item in metadata {
                            if let commonKey = item.commonKey {
                                if commonKey == .commonKeyTitle {
                                    if let value = try? await item.load(.value) as? String {
                                        loadedTitle = value
                                    }
                                } else if commonKey == .commonKeyArtist {
                                    if let value = try? await item.load(.value) as? String {
                                        loadedArtist = value
                                    }
                                } else if commonKey == .commonKeyArtwork {
                                    if let value = try? await item.load(.value) as? Data {
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
                
                resultBox.setResult(MetadataResult(title: loadedTitle, artist: loadedArtist, albumArt: loadedAlbumArt))
                semaphore.signal()
            }

                // Wait for metadata to load
            semaphore.wait()

            let metadataResult = resultBox.getResult()
            self.title = metadataResult.title ?? defaultTitle
            self.artist = metadataResult.artist ?? defaultArtist
            self.albumArt = metadataResult.albumArt
            self.metadataLoaded = true
        }
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

