import SwiftUI

struct WeeklyReportView: View {
    
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var history: [SharedDataManager.DayRecord] = []
    @State private var appeared = false
    
    var s: Strings { Strings(lang: localization.language) }
    
    // MARK: - الإحصاءات المحسوبة
    
    var avgDepth: Double {
        guard !history.isEmpty else { return 0 }
        return history.map {
            DepthScore(focusMinutes: $0.focusMinutes, distractionMinutes: $0.minutes).value
        }.reduce(0, +) / Double(history.count)
    }
    
    var totalFocusMinutes: Int {
        history.map(\.focusMinutes).reduce(0, +)
    }
    
    var totalDistractionMinutes: Int {
        history.map(\.minutes).reduce(0, +)
    }
    
    var bestDay: SharedDataManager.DayRecord? {
        history.filter { $0.focusMinutes > 0 }.max(by: { a, b in
            return DepthScore(focusMinutes: a.focusMinutes, distractionMinutes: a.minutes).value
                < DepthScore(focusMinutes: b.focusMinutes, distractionMinutes: b.minutes).value
        })
    }
    
    var weekTitle: String {
        switch avgDepth {
        case 0.8...:    return localization.isArabic ? "أسبوع استثنائي" : "Exceptional Week"
        case 0.6..<0.8: return localization.isArabic ? "أسبوع جيد" : "Good Week"
        case 0.4..<0.6: return localization.isArabic ? "أسبوع متوسط" : "Average Week"
        case 0.2..<0.4: return localization.isArabic ? "أسبوع صعب" : "Tough Week"
        default:        return localization.isArabic ? "الأسبوع القادم أفضل" : "Better Week Ahead"
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text(localization.isArabic ? "التقرير الأسبوعي" : "Weekly Report")
                            .font(.system(size: 13, weight: .ultraLight))
                            .tracking(6)
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Text(weekTitle)
                            .font(.system(size: 26, weight: .thin))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.top, 32)
                    
                    // MARK: - الكرة تعكس متوسط الأسبوع
                    ZStack {
                        DeepSphere(decayLevel: appeared ? 1.0 - avgDepth : 1.0)
                            .animation(.easeInOut(duration: 1.5), value: appeared)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(avgDepth * 100))%")
                                .font(.system(size: 28, weight: .ultraLight).monospacedDigit())
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text(localization.isArabic ? "متوسط العمق" : "Avg Depth")
                                .font(.system(size: 11, weight: .ultraLight))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    
                    // MARK: - البطاقات
                    HStack(spacing: 12) {
                        
                        // إجمالي التركيز
                        WeeklyStatCard(
                            title: localization.isArabic ? "التركيز" : "Focus",
                            value: formatTime(totalFocusMinutes),
                            icon: "brain",
                            decay: 1.0 - avgDepth
                        )
                        
                        // إجمالي التشتت
                        WeeklyStatCard(
                            title: localization.isArabic ? "التشتت" : "Distraction",
                            value: formatTime(totalDistractionMinutes),
                            icon: "wifi",
                            decay: min(Double(totalDistractionMinutes) / 1260.0, 1.0)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - أفضل يوم
                    if let best = bestDay {
                        let bestScore = DepthScore(
                            focusMinutes: best.focusMinutes,
                            distractionMinutes: best.minutes
                        )
                        
                        VStack(spacing: 12) {
                            Text(localization.isArabic ? "ذروة تركيزك" : "Peak Day")
                                .font(.system(size: 10, weight: .ultraLight))
                                .tracking(4)
                                .foregroundStyle(.white.opacity(0.3))
                            
                            HStack(spacing: 16) {
                                DeepSphere(decayLevel: bestScore.decayLevel)
                                    .scaleEffect(0.3)
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(fullDayName(best.date))
                                        .font(.system(size: 16, weight: .thin))
                                        .foregroundStyle(.white.opacity(0.85))
                                    
                                    Text("\(best.focusMinutes)m \(localization.isArabic ? "تركيز" : "focus") · \(best.minutes)m \(localization.isArabic ? "تشتت" : "distraction")")
                                        .font(.system(size: 12, weight: .ultraLight))
                                        .foregroundStyle(.white.opacity(0.35))
                                }
                                
                                Spacer()
                                
                                Text("\(Int(bestScore.value * 100))%")
                                    .font(.system(size: 24, weight: .ultraLight).monospacedDigit())
                                    .foregroundStyle(sphereColor(bestScore.decayLevel))
                            }
                            .padding(20)
                            .background(.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: - مقارنة بالأسبوع السابق
                    WeeklyComparisonRow(
                        currentAvg: avgDepth,
                        isArabic: localization.isArabic
                    )
                    .padding(.horizontal, 24)
                    
                    // زر الإغلاق
                    Button {
                        dismiss()
                    } label: {
                        Text(localization.isArabic ? "إغلاق" : "Done")
                            .font(.system(size: 14, weight: .ultraLight))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
        .onAppear {
            history = SharedDataManager.loadHistory()
            if history.isEmpty {
                history = SharedDataManager.mockHistory()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appeared = true
            }
        }
    }
    
    // MARK: - Helpers
    
    func formatTime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
    
    func fullDayName(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let d = formatter.date(from: date) else { return date }
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: localization.isArabic ? "ar" : "en")
        return formatter.string(from: d)
    }
}

// MARK: - WeeklyStatCard

struct WeeklyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let decay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .ultraLight))
                    .foregroundStyle(sphereColor(decay).opacity(0.7))
                
                Text(title)
                    .font(.system(size: 11, weight: .ultraLight))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            Text(value)
                .font(.system(size: 28, weight: .ultraLight).monospacedDigit())
                .foregroundStyle(sphereColor(decay))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - WeeklyComparisonRow

struct WeeklyComparisonRow: View {
    let currentAvg: Double
    let isArabic: Bool
    
    // (1) نقارن بالأسبوع السابق لو متوفر
    var previousAvg: Double? {
        let history = SharedDataManager.loadHistory()
        guard history.count >= 7 else { return nil }
        let previous = Array(history.prefix(history.count - 7))
        guard !previous.isEmpty else { return nil }
        return previous.map {
            DepthScore(focusMinutes: $0.focusMinutes, distractionMinutes: $0.minutes).value
        }.reduce(0, +) / Double(previous.count)
    }
    
    var body: some View {
        if let prev = previousAvg {
            let diff = currentAvg - prev
            let improved = diff >= 0
            
            HStack(spacing: 12) {
                Image(systemName: improved ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundStyle(improved ? .green.opacity(0.6) : .red.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isArabic ? "مقارنة بالأسبوع الماضي" : "vs Last Week")
                        .font(.system(size: 10, weight: .ultraLight))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.3))
                    
                    Text(improved
                         ? (isArabic ? "تحسّنت بنسبة \(Int(diff * 100))%" : "Improved by \(Int(diff * 100))%")
                         : (isArabic ? "انخفضت بنسبة \(Int(abs(diff) * 100))%" : "Down by \(Int(abs(diff) * 100))%"))
                        .font(.system(size: 14, weight: .thin))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(Int(prev * 100))%")
                    .font(.system(size: 18, weight: .ultraLight).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.25))
            }
            .padding(20)
            .background(.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    WeeklyReportView()
        .environmentObject(LocalizationManager.shared)
}
