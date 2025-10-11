import Foundation
import AVFoundation
import AppKit

struct Track: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    var title: String
    var artist: String
    var albumArt: NSImage?
    
    // Use a container class to safely pass data between concurrent contexts
    private final class MetadataContainer {
        var title: String?
        var artist: String?
        var albumArt: NSImage?
    }
    
    init(url: URL) {
        self.url = url
        
        // Extract metadata from MP3 file
        let asset = AVAsset(url: url)
        let defaultTitle = url.deletingPathExtension().lastPathComponent
        let defaultArtist = NSLocalizedString("Unknown Artist", comment: "Default artist name when metadata is missing")
        
        let container = MetadataContainer()
        
        // Use a dispatch group to synchronously wait for async metadata loading
        // Run on userInitiated QoS to avoid priority inversion when called from UI
        let group = DispatchGroup()
        group.enter()
        
        Task.detached(priority: .userInitiated) {
            do {
                let formats = try await asset.load(.availableMetadataFormats)
                
                for format in formats {
                    let metadata = try await asset.loadMetadata(for: format)
                    
                    for item in metadata {
                        if let commonKey = item.commonKey {
                            if commonKey == .commonKeyTitle {
                                if let value = try? await item.load(.stringValue) {
                                    container.title = value
                                }
                            } else if commonKey == .commonKeyArtist {
                                if let value = try? await item.load(.stringValue) {
                                    container.artist = value
                                }
                            } else if commonKey == .commonKeyArtwork {
                                if let value = try? await item.load(.dataValue) {
                                    container.albumArt = NSImage(data: value)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error loading metadata: \(error)")
            }
            group.leave()
        }
        
        group.wait()
        
        self.title = container.title ?? defaultTitle
        self.artist = container.artist ?? defaultArtist
        self.albumArt = container.albumArt
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

