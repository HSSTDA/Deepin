import Foundation

class SharedDataManager {
    
    static let appGroupID = "group.com.yourname.deepin"
    
    static var shared: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
    }
    
    enum Keys {
        static let decayLevel          = "decayLevel"
        static let totalMinutes        = "totalMinutesToday"
        static let lastUpdated         = "lastUpdated"
        static let history             = "usageHistory"
        static let selectedAppsTokens  = "selectedAppsTokens"
        static let monitoringActive    = "monitoringActive"
        static let focusMinutes        = "focusMinutesToday"  // ← جديد
    }

    // MARK: - Monitoring

    static func setMonitoringActive(_ active: Bool) {
        shared.set(active, forKey: Keys.monitoringActive)
    }

    static func isMonitoringActive() -> Bool {
        shared.bool(forKey: Keys.monitoringActive)
    }

    // MARK: - Decay

    static func saveDecay(_ level: Double) {
        shared.set(level, forKey: Keys.decayLevel)
        shared.set(Date(), forKey: Keys.lastUpdated)
    }
    
    static func loadDecay() -> Double {
        shared.double(forKey: Keys.decayLevel)
    }

    // MARK: - Distraction Minutes

    static func saveMinutes(_ minutes: Int) {
        shared.set(minutes, forKey: Keys.totalMinutes)
        let limit = 180.0
        let decay = min(Double(minutes) / limit, 1.0)
        saveDecay(decay)
        saveTodayToHistory(minutes: minutes)
    }
    
    static func loadMinutes() -> Int {
        shared.integer(forKey: Keys.totalMinutes)
    }

    // MARK: - Focus Minutes ← جديد

    static func saveFocusMinutes(_ minutes: Int) {
        shared.set(minutes, forKey: Keys.focusMinutes)
    }
    
    static func loadFocusMinutes() -> Int {
        shared.integer(forKey: Keys.focusMinutes)
    }

    // MARK: - History

    // نموذج يوم واحد في التاريخ
    struct DayRecord: Codable, Identifiable {
        var id: String { date }
        let date: String        // "2025-04-10"
        let minutes: Int        // دقائق التشتت
        let decay: Double
        let focusMinutes: Int   // دقائق التركيز ← جديد
        
        // (1) init مع قيمة افتراضية للـ focusMinutes
        // يضمن قراءة السجلات القديمة قبل إضافة الحقل بدون كراش
        init(date: String, minutes: Int, decay: Double, focusMinutes: Int = 0) {
            self.date = date
            self.minutes = minutes
            self.decay = decay
            self.focusMinutes = focusMinutes
        }
    }
    
    // حفظ بيانات اليوم في التاريخ
    static func saveTodayToHistory(minutes: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        // نقرأ دقائق التركيز الحالية لنحفظها مع السجل
        let currentFocusMinutes = loadFocusMinutes()
        
        var history = loadHistory()
        
        if let index = history.firstIndex(where: { $0.date == today }) {
            history[index] = DayRecord(
                date: today,
                minutes: minutes,
                decay: min(Double(minutes) / 180.0, 1.0),
                focusMinutes: currentFocusMinutes   // ← جديد
            )
        } else {
            history.append(DayRecord(
                date: today,
                minutes: minutes,
                decay: min(Double(minutes) / 180.0, 1.0),
                focusMinutes: currentFocusMinutes   // ← جديد
            ))
        }
        
        // نحتفظ بآخر 7 أيام فقط
        if history.count > 7 {
            history = Array(history.suffix(7))
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            shared.set(encoded, forKey: Keys.history)
        }
    }
    
    // قراءة التاريخ
    static func loadHistory() -> [DayRecord] {
        guard let data = shared.data(forKey: Keys.history),
              let decoded = try? JSONDecoder().decode([DayRecord].self, from: data)
        else { return [] }
        return decoded
    }
    
    // بيانات تجريبية للـ Preview
    static func mockHistory() -> [DayRecord] {
        let days    = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let distraction = [45, 120, 90, 180, 30, 150, 60]
        let focus       = [90,  30, 75,  20, 120,  45, 80]  // ← جديد
        
        return zip(days, zip(distraction, focus)).map { day, pair in
            let (dis, foc) = pair
            return DayRecord(
                date: day,
                minutes: dis,
                decay: min(Double(dis) / 180.0, 1.0),
                focusMinutes: foc
            )
        }
    }
    
    static func saveNote(_ note: String, for date: String) {
        shared.set(note, forKey: "note_\(date)")
    }

    static func loadNote(for date: String) -> String? {
        shared.string(forKey: "note_\(date)")
    }
}
