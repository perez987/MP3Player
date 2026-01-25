import Foundation

struct Language: Identifiable {
    let code: String
    let name: String
    let flag: String
    
    var id: String { code }
    
    static let available: [Language] = [
        Language(code: "de", name: "Deutsch", flag: "🇩🇪"),
        Language(code: "en", name: "English", flag: "🇬🇧"),
        Language(code: "es", name: "Español", flag: "🇪🇸"),
        Language(code: "fr", name: "Français", flag: "🇫🇷"),
        Language(code: "it", name: "Italiano", flag: "🇮🇹")
    ]
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let languageKey = "AppLanguage"
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: languageKey)
        }
    }
    
    init() {
        // Get saved language or use system language
        if let saved = UserDefaults.standard.string(forKey: languageKey) {
            currentLanguage = saved
        } else {
            // Get the first preferred language from system
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            let languageCode = String(systemLanguage.prefix(2))
            
            // Check if we support this language
            if Language.available.contains(where: { $0.code == languageCode }) {
                currentLanguage = languageCode
            } else {
                currentLanguage = "en"
            }
        }
    }
    
    func setLanguage(_ code: String) {
        // Validate that the language code exists in available languages
        guard Language.available.contains(where: { $0.code == code }) else {
            print("Warning: Invalid language code '\(code)' provided")
            return
        }
        
        currentLanguage = code
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
