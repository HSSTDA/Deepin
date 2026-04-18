import Foundation

struct Strings {
    
    let lang: AppLanguage
    
    var onboarding: [(title: String, subtitle: String)] {
        switch lang {
        case .english:
            return [
                (title: "Your Focus,\nVisualized.", subtitle: "Deepin reflects your screen time\nas a living sphere."),
                (title: "As You Drift,\nIt Fades.", subtitle: "The more time you spend on\ndistracting apps, the more it decays."),
                (title: "Stay Deep.", subtitle: "Choose which apps to monitor\nand set your daily limit.")
            ]
        case .arabic:
            return [
                (title: "صورة من داخلك", subtitle: "كرة حية تعكس وقتك وتركيزك"),
                (title: "تشتتك يترك أثراً", subtitle: "كلما ابتعدت، تلاشت الكرة أمامك"),
                (title: "ابنِ عمقك", subtitle: "اختر ما تراقبه وضع حدودك اليومية")
            ]
        }
    }
    
    func focusLabel(for decay: Double) -> String {
        switch lang {
        case .english:
            switch decay {
            case 0.0..<0.3: return "Deep Focus"
            case 0.3..<0.6: return "Drifting..."
            case 0.6..<0.9: return "Losing Ground"
            default:         return "Distracted"
            }
        case .arabic:
            switch decay {
            case 0.0..<0.3: return "تركيز"
            case 0.3..<0.6: return "شارد"
            case 0.6..<0.9: return "مشوش"
            default:         return "متشتت"
            }
        }
    }
    
    var stats: String             { lang == .arabic ? "الإحصاءات"                      : "Stats" }
    var setup: String             { lang == .arabic ? "ضبط"                             : "Setup" }
    var done: String              { lang == .arabic ? "إغلاق"                           : "Done" }
    var focus: String             { lang == .arabic ? "تركيز"                           : "Focus" }
    var distraction: String       { lang == .arabic ? "تشتت"                            : "Distraction" }
    var depthScore: String        { lang == .arabic ? "عمق تركيزك"                      : "Depth Score" }
    var tapToStart: String        { lang == .arabic ? "اضغط للبدء"                      : "Tap to start focusing" }
    var tapToEnd: String          { lang == .arabic ? "اضغط للإنهاء"                    : "Tap to end session" }
    var today: String             { lang == .arabic ? "اليوم"                           : "Today" }
    var avgDepth: String          { lang == .arabic ? "متوسط العمق"                     : "Avg Depth" }
    var weeklyOverview: String    { lang == .arabic ? "ملخص الأسبوع"                    : "Weekly Overview" }
    var bestFocusDay: String      { lang == .arabic ? "ذروة تركيزك"                     : "Best Focus Day" }
    var noAppsMonitored: String   { lang == .arabic ? "لم تحدد تطبيقات بعد"            : "No apps monitored" }
    var noFocusSession: String    { lang == .arabic ? "ابدأ جلسة تركيز لترى أفضل أيامك" : "Start a focus session to see your best day" }
    var startFocusSession: String { lang == .arabic ? "ابدأ جلسة تركيز"                : "Start Focus Session" }
    var shieldTitle: String       { lang == .arabic ? "وصلت للحد"                       : "Time's up." }
    var shieldSubtitle: String    { lang == .arabic ? "تركيزك يستحق الحماية"            : "You've reached your limit.\nYour focus is worth protecting." }
    var shieldReset: String       { lang == .arabic ? "غداً صفحة جديدة"                 : "Resets at midnight" }
    var minUsed: String           { lang == .arabic ? "د مستخدمة"                       : "min used" }
    var remaining: String         { lang == .arabic ? "متبقية"                          : "remaining" }
    var thisWeek: String          { lang == .arabic ? "هذا الأسبوع"                     : "this week" }
    var minDistracted: String     { lang == .arabic ? "د تشتت"                          : "min distracted" }
}
