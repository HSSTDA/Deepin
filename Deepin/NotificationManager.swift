import UserNotifications
import Foundation

class NotificationManager {
    
    static let shared = NotificationManager()
    
    // (1) طلب إذن الإشعارات
    func requestAuthorization() async {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Notification auth failed: \(error)")
        }
    }
    
    // (2) إشعار اقتراب من حد الاستخدام
    func scheduleWarning(
        minutesUsed: Int,
        distractionLimit: Int,
        isArabic: Bool
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let remaining = distractionLimit - minutesUsed
        let ratio = Double(minutesUsed) / Double(distractionLimit)
        
        // (3) نرسل فقط عند 80% و 100%
        guard ratio >= 0.8 else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if ratio >= 1.0 {
            // تجاوز الحد
            content.title = isArabic ? "وصلت للحد" : "Limit Reached"
            content.body = isArabic
                ? "تجاوزت حد التشتت اليومي — تركيزك يستحق الحماية"
                : "You've hit your distraction limit — your focus matters"
        } else {
            // اقترب من الحد
            content.title = isArabic ? "تنبيه" : "Heads up"
            content.body = isArabic
                ? "تبقّى \(remaining) دقيقة من حد التشتت"
                : "\(remaining) minutes left in your distraction limit"
        }
        
        // (4) يُرسل فوراً
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "deepin.warning.\(ratio >= 1.0 ? "over" : "near")",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // (5) إشعار تحقيق هدف التركيز
    func scheduleFocusAchieved(isArabic: Bool) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = isArabic ? "أحسنت" : "Goal Achieved"
        content.body = isArabic
            ? "حققت هدف تركيزك اليوم — الكرة في أفضل حالاتها"
            : "You've hit your focus goal — your sphere is at its best"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "deepin.focus.achieved",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // (6) إشعار رفع الحد — التحذير الأهم
    func scheduleGoalChangedWarning(
        oldLimit: Int,
        newLimit: Int,
        isArabic: Bool
    ) {
        guard newLimit > oldLimit else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = isArabic ? "لاحظنا تغييراً" : "Limit Increased"
        content.body = isArabic
            ? "رفعت حد التشتت — هذا سيؤثر على عمق تركيزك ومعدلك الأسبوعي"
            : "You raised your limit — this will affect your depth score and weekly average"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "deepin.limit.raised",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
}
