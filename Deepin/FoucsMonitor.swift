import SwiftUI
import FamilyControls
import ManagedSettings
import Combine

@MainActor
class FocusMonitor: ObservableObject {
    
    @Published var decayLevel: Double = 0.0
    @Published var isAuthorized: Bool = false
    @Published var totalMinutesToday: Int = 0
    
    // (1) نقرأ الأهداف الشخصية دائماً من UserDefaults
    var dailyLimitMinutes: Int {
        let saved = UserDefaults.standard.integer(forKey: "distractionLimitMinutes")
        return saved == 0 ? 60 : saved
    }
    
    var focusGoalMinutes: Int {
        let saved = UserDefaults.standard.integer(forKey: "focusGoalMinutes")
        return saved == 0 ? 90 : saved
    }
    
    private let authCenter = AuthorizationCenter.shared
    
    // (2) تتبع ما إذا أرسلنا إشعار التركيز اليوم
    private var focusAchievedNotified = false
    
    func requestAuthorization() async {
        do {
            try await authCenter.requestAuthorization(for: .individual)
            isAuthorized = true
            // (3) نطلب إذن الإشعارات معها
            await NotificationManager.shared.requestAuthorization()
        } catch {
            isAuthorized = false
        }
    }
    
    func updateDecay(minutes: Int) {
        totalMinutesToday = minutes
        
        let decay = min(Double(minutes) / Double(dailyLimitMinutes), 1.0)
        
        withAnimation(.easeInOut(duration: 1.5)) {
            decayLevel = decay
        }
        
        SharedDataManager.saveMinutes(minutes)
        
        // (4) نتحقق من الإشعارات
        checkNotifications(minutes: minutes)
    }
    
    // (5) تحديث دقائق التركيز وتحقق من الهدف
    func updateFocusMinutes(_ minutes: Int) {
        SharedDataManager.saveFocusMinutes(minutes)
        
        let isArabic = UserDefaults.standard.string(forKey: "appLanguage") == "ar"
        
        // إشعار تحقيق هدف التركيز — مرة واحدة فقط
        if minutes >= focusGoalMinutes && !focusAchievedNotified {
            focusAchievedNotified = true
            NotificationManager.shared.scheduleFocusAchieved(isArabic: isArabic)
        }
    }
    
    private func checkNotifications(minutes: Int) {
        let isArabic = UserDefaults.standard.string(forKey: "appLanguage") == "ar"
        
        NotificationManager.shared.scheduleWarning(
            minutesUsed: minutes,
            distractionLimit: dailyLimitMinutes,
            isArabic: isArabic
        )
    }
}
