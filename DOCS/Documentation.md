# MP3Player Documentation

## Overview

MP3Player is a SwiftUI-based macOS application designed to play MP3 and M4A audio files with a clean, modern interface. The application follows SwiftUI best practices and demonstrates proper use of modern Swift concurrency features, state management, and system integrations.

## Project Structure

The project is organized into several key components:

- **Mp3PlayerApp.swift**: Main application entry point, defines the app structure, menus, and keyboard shortcuts
- **ContentView.swift**: Main user interface view with playback controls and track display
- **AudioPlayerManager.swift**: Manages audio playback using AVAudioPlayer
- **PlaylistManager.swift**: Handles playlist logic, track ordering, and shuffle functionality
- **Track.swift**: Data model representing an audio track with metadata
- **MenuBarManager.swift**: Manages menu bar icon and system notifications
- **ScrollingText.swift**: Custom view for animated scrolling text display
- **AppDelegate.swift**: Application delegate for system event handling

## Key Features and Implementation

### 1. Audio File Support

**Supported Formats**: MP3 and M4A files

**Implementation**:
- Uses `AVAudioPlayer` for audio playback (AudioPlayerManager.swift)
- UTType definitions for file type filtering: `.mp3` and `.mpeg4Audio`
- Metadata extraction using `AVAsset` to retrieve title, artist, and album artwork

### 2. File Loading Mechanisms

**Single File Loading**:
- File picker dialog using `NSOpenPanel`
- Support for opening files via Finder (Open With...)
- Security-scoped bookmarks for persistent file access

**Directory Loading**:
- Recursive directory enumeration to find all MP3/M4A files
- Alphabetical sorting of tracks by filename
- Lazy metadata loading to prevent system rate limiting

**Implementation Details** (PlaylistManager.swift):
```swift
func loadFile(_ url: URL)              // Load single file with immediate metadata
func loadDirectory(_ url: URL)         // Load all audio files from directory
```

### 3. Playback Controls

**Available Controls**:
- Play/Pause toggle
- Stop
- Previous track
- Next track
- Shuffle mode

**Keyboard Shortcuts** (Mp3PlayerApp.swift):
- `Ctrl+P`: Play/Pause
- `Ctrl+S`: Stop
- `Ctrl+A`: Previous track
- `Ctrl+N`: Next track
- `Ctrl+H`: Toggle shuffle

**Implementation**:
- Menu commands post notifications to NotificationCenter
- ContentView observes notifications and triggers appropriate actions
- State management using `@Published` properties in ObservableObject classes

### 4. Metadata Handling

**Extracted Metadata**:
- Song title
- Artist name
- Album artwork

**Lazy Loading Strategy** (Track.swift):
- When loading a directory, tracks are created without metadata (`loadMetadata: false`)
- Metadata is loaded on-demand when a track starts playing
- Prevents system message rate limiting when loading large directories
- Uses async/await with AVAsset for modern concurrency

**Key Implementation**:
```swift
init(url: URL, loadMetadata: Bool = true)
```

### 5. Security-Scoped Resources

**Purpose**: Maintain file access permissions across app launches

**Implementation** (AudioPlayerManager.swift, PlaylistManager.swift):
- Security-scoped bookmarks created for user-selected files and directories
- Proper resource access lifecycle:
  - `startAccessingSecurityScopedResource()` before file operations
  - `stopAccessingSecurityScopedResource()` after completion
- Bookmarks stored in UserDefaults for persistence
- Separate handling for standalone files vs. directory-loaded files

### 6. State Persistence

**Saved State**:
- Last played track (file path)
- Last played directory (if applicable)
- Security-scoped bookmarks for restoration

**Restoration Flow** (PlaylistManager.swift):
1. Attempt to restore from directory bookmark (if directory was previously loaded)
2. Fall back to single file bookmark if directory restoration fails
3. Restore playback position within playlist
4. Maintain shuffle state and order

### 7. Shuffle Mode

**Functionality**:
- Random playback order
- Enabled by default when loading a directory
- Maintains consistent shuffle order during playback session

**Implementation** (PlaylistManager.swift):
```swift
var shuffledIndices: [Int]              // Pre-shuffled track indices
var currentShufflePosition: Int         // Current position in shuffle
```

### 8. User Interface

**Layout** (ContentView.swift):
- ZStack with blurred album art background
- Track information display with scrolling title
- Time display (elapsed and remaining)
- Progress slider for seeking
- Control buttons
- Playlist information (track count, directory path)

**Dynamic Elements**:
- ScrollingText view for long song titles
- Album art background with blur effect
- Disabled state for controls when no playlist loaded

### 9. Menu Bar Integration

**Features** (MenuBarManager.swift):
- Music note icon in macOS menu bar
- Shows app is running even when window is minimized

### 10. System Notifications

**Platform Requirement**: macOS 15 (Sequoia) and later

**Functionality**:
- Displays notification when song changes
- Shows track title and artist
- Silent notifications (no sound)
- Appears even when app is in foreground

**Implementation** (MenuBarManager.swift):
- Uses UserNotifications framework
- Requests notification permissions at startup
- Unique identifier for each notification to prevent grouping
- Notification delegate ensures display in foreground

**Compatibility Note**:
- Notifications disabled on macOS 14 and earlier due to compatibility issues
- Menu bar icon still functions on all supported macOS versions

### 11. Localization

**Supported Languages**: English and Spanish

**Implementation**:
- NSLocalizedString for all user-facing text
- Separate .lproj directories for each language
- Localizable strings for UI elements, menu items, and tooltips

### 12. Window Management

**Configuration** (Mp3PlayerApp.swift):
- Fixed window size: 500x350 pixels
- Content-based resizability (macOS 13+)
- Window group architecture for multi-window support

### 13. Notification System Architecture

**Central Communication**:
- Uses NotificationCenter for decoupled component communication
- Custom notification names defined as Notification.Name extensions

**Key Notifications**:
- `.openFile`, `.openDirectory`: File/directory opening commands
- `.playPrevious`, `.playNext`: Track navigation
- `.playTogglePlayPause`, `.playStop`: Playback control
- `.playToggleShuffle`: Shuffle mode toggle
- `.trackFinished`: Automatic next track when playback completes
- `.trackChanged`: Track change event for menu bar notifications

## Technical Considerations

### Rate Limiting Prevention

**Problem**: Loading metadata for many files simultaneously causes system message flooding

**Solution**:
- Deferred metadata loading when opening directories
- Metadata loaded only when track starts playing
- Sequential processing instead of parallel batch loading

### Memory Management

**Proper Resource Cleanup**:
- Deinitializers stop security-scoped resource access
- Timer invalidation in AudioPlayerManager
- Proper AVAudioPlayer delegate pattern

### Concurrency

**Modern Patterns**:
- Swift async/await for metadata loading
- DispatchQueue for background preparation
- @MainActor updates for UI state changes
- Semaphores for controlled synchronization

### SwiftUI State Management

**Architecture**:
- `@StateObject` for object lifecycle tied to view
- `@ObservableObject` classes with `@Published` properties
- `@EnvironmentObject` for dependency injection
- Unidirectional data flow

## Building and Running

**Requirements**:
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5

**Build Process**:
1. Open `Mp3Player.xcodeproj` in Xcode
2. Select target architecture (Apple Silicon or Intel)
3. Build and run

## Known Issues and Limitations

1. **Notification Compatibility**: Song change notifications only work on macOS 15+
2. **Rate Limiting**: Fixed by lazy metadata loading, but mentioned in Console-messages.md as a previous issue
3. **Gatekeeper**: Ad-hoc signed, not notarized, requires manual security approval

## Future Enhancements

Potential areas for improvement:
- Extended format support (FLAC, AAC, etc.)
- Playlist save/load functionality
- Equalizer controls
- Repeat mode options
- Volume control
- Dark/light mode customization
- Custom theme support
