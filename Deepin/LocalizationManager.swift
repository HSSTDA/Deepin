import SwiftUI
import Combine  // ← أضف هذا

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case arabic  = "ar"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic:  return "العربية"
        }
    }
}

class LocalizationManager: ObservableObject {
    
    static let shared = LocalizationManager()
    
    @Published var language: AppLanguage
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        self.language = AppLanguage(rawValue: saved) ?? .english
    }
    
    func setLanguage(_ lang: AppLanguage) {
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
    }
    
    var isArabic: Bool { language == .arabic }
    
    func toggle() {
        setLanguage(isArabic ? .english : .arabic)
    }
}
