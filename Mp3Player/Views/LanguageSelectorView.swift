import SwiftUI
import AppKit

// Helper to find the hosting window
struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            // Ensure view is still valid and has been added to window hierarchy
            self.callback(view?.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed - window reference is captured once during initialization
    }
}

struct LanguageSelectorView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: String
    @State private var showRestartAlert = false
    @State private var window: NSWindow?
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("Language Selector", comment: "Language Selector window title"))
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Divider()
            
            // Language list
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Language.available) { language in
                    Button(action: {
                        selectedLanguage = language.code
                    }) {
                        HStack(spacing: 12) {
                            Text(language.flag)
                                .font(.title2)
                            
                            Text(language.name)
                                .font(.body)
                            
                            Spacer()
                            
                            if selectedLanguage == language.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .frame(width: 240)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        selectedLanguage == language.code ?
                        Color.accentColor.opacity(0.1) : Color.clear
                    )
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            // Buttons
            HStack(spacing: 12) {
                Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                    window?.close()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(NSLocalizedString("Accept", comment: "Accept button")) {
                    // Only show alert if language actually changed
                    if selectedLanguage != languageManager.currentLanguage {
                        languageManager.setLanguage(selectedLanguage)
                        showRestartAlert = true
                    } else {
                        window?.close()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 340, height: 400)
        .background(
            HostingWindowFinder { foundWindow in
                window = foundWindow
            }
        )
        .alert(NSLocalizedString("Restart Required", comment: "Restart Required alert title"),
               isPresented: $showRestartAlert) {
            Button(NSLocalizedString("OK", comment: "OK button")) {
                // Close the window using the stored reference
                window?.close()
            }
        } message: {
            Text(NSLocalizedString("The application must be restarted for the language change to take effect.", 
                                 comment: "Restart message"))
        }
    }
}

#Preview {
    LanguageSelectorView()
}
