import SwiftUI
import FamilyControls

@main
struct DeepinApp: App {
    
    @StateObject private var focusMonitor = FocusMonitor()
    @StateObject private var monitoringManager = MonitoringManager.shared
    @StateObject private var localization = LocalizationManager.shared
    
    @AppStorage("hasCompletedOnboarding") var hasCompleted = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompleted {
                ContentView()
                    .environmentObject(focusMonitor)
                    .environmentObject(monitoringManager)
                    .environmentObject(localization)
                    .task {
                        await focusMonitor.requestAuthorization()
                        await NotificationManager.shared.requestAuthorization()
                        // جدولة الإشعارات
                        let isArabic = localization.isArabic
                        WeeklyReportManager.shared.scheduleWeeklyReport(isArabic: isArabic)
                        DailyNoteManager.shared.scheduleDailyNoteReminder(isArabic: isArabic)
                    }
                    .onAppear {
                        let saved = SharedDataManager.loadDecay()
                        focusMonitor.updateDecay(
                            minutes: Int(saved * Double(focusMonitor.dailyLimitMinutes))
                        )
                    }
            } else {
                OnboardingView()
                    .environmentObject(localization)
                    .environmentObject(monitoringManager)
            }
        }
    }
}
