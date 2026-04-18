import UserNotifications
import Foundation

class WeeklyReportManager {
    
    static let shared = WeeklyReportManager()
    
    // (1) جدولة التقرير كل أحد الساعة 8 مساءً
    func scheduleWeeklyReport(isArabic: Bool) {
        let center = UNUserNotificationCenter.current()
        
        // نلغي أي تقرير قديم
        center.removePendingNotificationRequests(
            withIdentifiers: ["deepin.weekly.report"]
        )
        
        let content = buildReportContent(isArabic: isArabic)
        
        // (2) كل أحد الساعة 8 مساءً
        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // الأحد
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "deepin.weekly.report",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // (3) بناء محتوى التقرير من البيانات الحقيقية
    private func buildReportContent(isArabic: Bool) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        let history = SharedDataManager.loadHistory()
        
        guard !history.isEmpty else {
            content.title = isArabic ? "تقريرك الأسبوعي" : "Weekly Report"
            content.body = isArabic
                ? "ابدأ جلسات تركيز لترى تقريرك الأسبوعي"
                : "Start focus sessions to see your weekly report"
            return content
        }
        
        // (4) نحسب الإحصاءات
        let avgDepth = history.map {
            DepthScore(
                focusMinutes: $0.focusMinutes,
                distractionMinutes: $0.minutes
            ).value
        }.reduce(0, +) / Double(history.count)
        
        let bestDay = history.max(by: { a, b in
            return DepthScore(focusMinutes: a.focusMinutes, distractionMinutes: a.minutes).value
                < DepthScore(focusMinutes: b.focusMinutes, distractionMinutes: b.minutes).value
        })
        
        let totalFocusMinutes = history.map(\.focusMinutes).reduce(0, +)
        let totalHours = totalFocusMinutes / 60
        let totalMins = totalFocusMinutes % 60
        
        // (5) نختار العنوان بناءً على الأداء
        content.title = weeklyTitle(avgDepth: avgDepth, isArabic: isArabic)
        
        // (6) بناء نص التقرير
        var body = ""
        
        if isArabic {
            body += "متوسط العمق: \(Int(avgDepth * 100))%\n"
            body += "إجمالي التركيز: \(totalHours)س \(totalMins)د\n"
            if let best = bestDay {
                body += "أفضل يوم: \(shortDayName(best.date, isArabic: true))"
            }
        } else {
            body += "Avg depth: \(Int(avgDepth * 100))%\n"
            body += "Total focus: \(totalHours)h \(totalMins)m\n"
            if let best = bestDay {
                body += "Best day: \(shortDayName(best.date, isArabic: false))"
            }
        }
        
        content.body = body
        return content
    }
    
    // (7) عنوان يعكس الأداء الأسبوعي
    private func weeklyTitle(avgDepth: Double, isArabic: Bool) -> String {
        switch avgDepth {
        case 0.8...:
            return isArabic ? "أسبوع استثنائي 🔵" : "Exceptional week 🔵"
        case 0.6..<0.8:
            return isArabic ? "أسبوع جيد" : "Good week"
        case 0.4..<0.6:
            return isArabic ? "أسبوع متوسط — يمكن أفضل" : "Average week — you can do better"
        case 0.2..<0.4:
            return isArabic ? "أسبوع صعب — ابدأ من جديد" : "Tough week — fresh start ahead"
        default:
            return isArabic ? "الأسبوع القادم فرصة جديدة" : "New week, new chance"
        }
    }
    
    // (8) اسم اليوم المختصر
    private func shortDayName(_ date: String, isArabic: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let d = formatter.date(from: date) else {
            return String(date.prefix(3))
        }
        
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: isArabic ? "ar" : "en")
        return formatter.string(from: d)
    }
}
