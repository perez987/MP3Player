# Mp3Player in SwiftUI

![Platform](https://img.shields.io/badge/macOS-13+-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5-color=9494ff.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.2+-lavender.svg)

A simple SwiftUI app for macOS to play MP3 files.

<img src="Images/Main-window.png" width="600px">

## Features

- **Open MP3 Files**: Open a single MP3 file to play
- **Open Directories**: Load all MP3 files from a directory
- **Playback Controls**: Play/Pause, Stop, Previous, Next buttons
- **Play Menu**: Dedicated menu with keyboard shortcuts for playback controls
- **Shuffle Mode**: Random playback of tracks
- **Time Display**: Shows elapsed time and remaining time for current track
- **Track Information**: Displays song title and artist extracted from MP3 metadata
- **Persistent State**: Automatically saves and restores the last played track
- **Open with Finder**: Support for opening MP3 files via Finder
- **Album Art Background**: Displays album artwork as a blurred background when available
- **Languages**: English and Spanish.

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later

## Usage

1. Use the File menu or keyboard shortcuts to open:
 	- Single File: Press `Cmd+O` or go to `File > Open MP3 File...`
	- Directory: Press `Cmd+D` or go to `File > Open Directory...`

2. Use the Play menu or keyboard shortcuts for playback control:
 	- ⏪️ Previous track: `Ctrl+A` or go to `Play > Previous`
 	- ▶️ Play / ⏸️ Pause: `Ctrl+P` or go to `Play > Play/Pause`
 	- ⏹️ Stop playback: `Ctrl+S` or go to `Play > Stop`
 	- ⏩️ Next track: `Ctrl+N` or go to `Play > Next`
 	- 🔀 Toggle shuffle mode: `Ctrl+H` or go to `Play > Shuffle`
	
3. Right button on a MP3 file to open it via Finder.

## App is damaged and can't be opened

If you see `App is damaged and can't be opened` when you open MP3Player for the first time, read [App-damaged.md](DOCS/App-damaged.md).

## Console Messages

You may see various console messages when running the app in Xcode. Most of these are harmless system messages from macOS frameworks. For a detailed explanation of what each message means and which ones are safe to ignore, see [Console-messages.md](DOCS/Console-messages.md).

## Building

Open `Mp3Player.xcodeproj` in Xcode and build the project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
