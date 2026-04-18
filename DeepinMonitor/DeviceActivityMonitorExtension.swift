import DeviceActivity
import ManagedSettings
import FamilyControls
import SwiftUI

class DeepinActivityMonitor: DeviceActivityMonitor {
    
    // (1) هذا المتجر هو الذي يطبق الحظر الفعلي
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        SharedDataManager.saveMinutes(0)
        // نرفع الحظر في بداية اليوم الجديد
        store.shield.applications = nil
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
    }
    
    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        
        let currentMinutes = SharedDataManager.loadMinutes()
        SharedDataManager.saveMinutes(currentMinutes + 15)
        
        // (2) عند تجاوز الحد النهائي — نطبق الحظر
        if event == .sixtyMinutes {
            applyShield()
        }
    }
    
    // (3) تطبيق الحظر مع شاشة Deepin المخصصة
    func applyShield() {
        guard let data = UserDefaults(suiteName: SharedDataManager.appGroupID)?
            .data(forKey: SharedDataManager.Keys.selectedAppsTokens),
              let tokens = try? JSONDecoder().decode(
                Set<ApplicationToken>.self,
                from: data
              )
        else { return }
        
        store.shield.applications = tokens
        
        // (4) نخبر الشاشة الرئيسية بتحديث الـ Widget
        store.shield.applicationCategories = nil
    }
}
