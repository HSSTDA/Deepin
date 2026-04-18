import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import Combine

class MonitoringManager: ObservableObject {
    
    static let shared = MonitoringManager()
    
    // (1) اسم "جلسة المراقبة" — معرّف فريد
    let activityName = DeviceActivityName("com.yourname.deepin.daily")
    
    // (2) التطبيقات المحددة للمراقبة — يختارها المستخدم
    @Published var selectedApps = FamilyActivitySelection() {
        didSet {
            if let encoded = try? JSONEncoder().encode(selectedApps.applicationTokens) {
                SharedDataManager.shared.set(encoded, forKey: SharedDataManager.Keys.selectedAppsTokens)
            }
        }
    }
    
    private let center = DeviceActivityCenter()
    
    // (3) تشغيل المراقبة
    func startMonitoring() {
        // نحدد الفترة الزمنية: من منتصف الليل لمنتصف الليل
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true  // (4) يتكرر كل يوم تلقائياً
        )
        
        // (5) نحدد "الأحداث" التي نريد مراقبتها
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .fifteenMinutes: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 15)  // كل 15 دقيقة
            ),
            .thirtyMinutes: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 30)
            ),
            .sixtyMinutes: DeviceActivityEvent(
                applications: selectedApps.applicationTokens,
                threshold: DateComponents(minute: 60)
            )
        ]
        
        do {
            try center.startMonitoring(
                activityName,
                during: schedule,
                events: events
            )
            SharedDataManager.setMonitoringActive(true)
        } catch {
            print("Monitoring failed: \(error)")
        }
    }

    // (6) إيقاف المراقبة
    func stopMonitoring() {
        center.stopMonitoring([activityName])
        SharedDataManager.setMonitoringActive(false)
    }
}

// (7) أسماء الأحداث — نجمعها في مكان واحد
extension DeviceActivityEvent.Name {
    static let fifteenMinutes = Self("fifteenMinutes")
    static let thirtyMinutes  = Self("thirtyMinutes")
    static let sixtyMinutes   = Self("sixtyMinutes")
}
