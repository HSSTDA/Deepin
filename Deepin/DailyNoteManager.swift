import UserNotifications
import Foundation

class DailyNoteManager {
    
    static let shared = DailyNoteManager()
    
    // (1) جدولة إشعار نهاية اليوم — الساعة 9 مساءً
    func scheduleDailyNoteReminder(isArabic: Bool) {
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(
            withIdentifiers: ["deepin.daily.note"]
        )
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = isArabic ? "كيف كان يومك؟" : "How was your day?"
        content.body = isArabic
            ? "دوّن ملاحظة عن يومك قبل أن ينتهي"
            : "Write a quick note before the day ends"
        
        // (2) كل يوم الساعة 9 مساءً
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "deepin.daily.note",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // (3) حفظ الملاحظة
    static func saveNote(_ note: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        SharedDataManager.shared.set(note, forKey: "note_\(today)")
    }
    
    // (4) قراءة ملاحظة يوم معين
    static func loadNote(for date: String) -> String? {
        SharedDataManager.shared.string(forKey: "note_\(date)")
    }
    
    // (5) قراءة ملاحظة اليوم
    static func loadTodayNote() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return loadNote(for: today)
    }
}
