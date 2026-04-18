import SwiftUI

struct StatsView: View {
    
    @EnvironmentObject var focusMonitor: FocusMonitor
    @EnvironmentObject var localization: LocalizationManager
    @State private var history: [SharedDataManager.DayRecord] = []
    @State private var showWeeklyReport = false
    @State private var showDailyNote = false
    
    var s: Strings { Strings(lang: localization.language) }
    
    var bestFocusDay: SharedDataManager.DayRecord? {
        history
            .filter { $0.focusMinutes > 0 }
            .max(by: { a, b in
                return DepthScore(
                    focusMinutes: a.focusMinutes,
                    distractionMinutes: a.minutes
                ).value
                < DepthScore(
                    focusMinutes: b.focusMinutes,
                    distractionMinutes: b.minutes
                ).value
            })
    }
    
    var weeklyDepthScore: Double {
        guard !history.isEmpty else { return 0 }
        let total = history.map {
            DepthScore(
                focusMinutes: $0.focusMinutes,
                distractionMinutes: $0.minutes
            ).value
        }.reduce(0, +)
        return total / Double(history.count)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    
                    // MARK: - الهيدر
                    VStack(spacing: 6) {
                        Text(s.stats)
                            .font(.system(size: 14, weight: .light))
                            .tracking(8)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Text("Last 7 days")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.top, 20)
                    
                    // MARK: - زر التقرير الأسبوعي
                    Button {
                        showWeeklyReport = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 11, weight: .ultraLight))
                            Text(localization.isArabic ? "التقرير الأسبوعي" : "Weekly Report")
                                .font(.system(size: 11, weight: .ultraLight))
                                .tracking(2)
                        }
                        .foregroundStyle(.white.opacity(0.3))
                    }
                    .sheet(isPresented: $showWeeklyReport) {
                        WeeklyReportView()
                            .environmentObject(localization)
                    }
                    
                    // MARK: - البطاقات العلوية
                    HStack(spacing: 16) {
                        StatCard(
                            title: s.today,
                            value: "\(focusMonitor.totalMinutesToday)",
                            unit: s.minDistracted,
                            decay: focusMonitor.decayLevel
                        )
                        
                        StatCard(
                            title: s.avgDepth,
                            value: "\(Int(weeklyDepthScore * 100))",
                            unit: "% \(s.thisWeek)",
                            decay: 1.0 - weeklyDepthScore
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - الرسم البياني
                    VStack(alignment: .leading, spacing: 16) {
                        Text(s.weeklyOverview.uppercased())
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.horizontal, 24)
                        
                        if history.isEmpty {
                            Text(s.noFocusSession)
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            DualBarChartView(
                                history: history,
                                focusLabel: s.focus,
                                distractionLabel: s.distraction
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // MARK: - Best Focus Day
                    if let best = bestFocusDay {
                        let bestScore = DepthScore(
                            focusMinutes: best.focusMinutes,
                            distractionMinutes: best.minutes
                        )
                        
                        VStack(spacing: 12) {
                            Text(s.bestFocusDay.uppercased())
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.4))
                            
                            HStack(spacing: 12) {
                                DeepSphere(decayLevel: bestScore.decayLevel)
                                    .scaleEffect(0.35)
                                    .frame(width: 60, height: 60)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(best.date)
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Text("\(best.focusMinutes)m \(s.focus) · \(best.minutes)m \(s.distraction)")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 2) {
                                    Text("\(Int(bestScore.value * 100))%")
                                        .font(.system(size: 22, weight: .thin))
                                        .foregroundStyle(sphereColor(bestScore.decayLevel))
                                    
                                    Text(s.depthScore)
                                        .font(.system(size: 9, weight: .light))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                            }
                            .padding(20)
                            .background(.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.horizontal, 24)
                        
                    } else {
                        VStack(spacing: 8) {
                            Text(s.bestFocusDay.uppercased())
                                .font(.system(size: 10, weight: .light))
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.4))
                            
                            Text(s.noFocusSession)
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(.white.opacity(0.25))
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 24)
                                .frame(maxWidth: .infinity)
                                .background(.white.opacity(0.03))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: - ملاحظة اليوم
                    VStack(spacing: 12) {
                        Text(localization.isArabic ? "ملاحظة اليوم" : "Today's Note")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.4))
                        
                        Button {
                            showDailyNote = true
                        } label: {
                            HStack {
                                if let note = DailyNoteManager.loadTodayNote() {
                                    Text(note)
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                } else {
                                    Text(localization.isArabic
                                         ? "اضغط لتكتب ملاحظتك عن اليوم"
                                         : "Tap to write today's note")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundStyle(.white.opacity(0.25))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .ultraLight))
                                    .foregroundStyle(.white.opacity(0.2))
                            }
                            .padding(20)
                            .background(.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal, 24)
                    .sheet(isPresented: $showDailyNote) {
                        DailyNoteView()
                            .environmentObject(localization)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
        .onAppear { loadData() }
    }
    
    func loadData() {
        history = SharedDataManager.loadHistory()
        if history.isEmpty {
            history = SharedDataManager.mockHistory()
        }
    }
}

// MARK: - DualBarChartView

struct DualBarChartView: View {
    let history: [SharedDataManager.DayRecord]
    let focusLabel: String
    let distractionLabel: String
    
    var maxMinutes: Double {
        let maxDistraction = history.map(\.minutes).max() ?? 180
        let maxFocus = history.map(\.focusMinutes).max() ?? 180
        return Double(max(maxDistraction, maxFocus, 1))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            if history.allSatisfy({ $0.focusMinutes == 0 }) {
                Text("Start a focus session to see your comparison")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
            }
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(history) { record in
                    let score = DepthScore(
                        focusMinutes: record.focusMinutes,
                        distractionMinutes: record.minutes
                    )
                    
                    VStack(spacing: 6) {
                        HStack(alignment: .bottom, spacing: 2) {
                            
                            // شريط التركيز
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            sphereColor(score.decayLevel).opacity(0.9),
                                            sphereColor(score.decayLevel).opacity(0.4)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: 10,
                                    height: max(
                                        CGFloat(Double(record.focusMinutes) / maxMinutes) * 120,
                                        4
                                    )
                                )
                            
                            // شريط التشتت
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.12))
                                .frame(
                                    width: 10,
                                    height: max(
                                        CGFloat(Double(record.minutes) / maxMinutes) * 120,
                                        4
                                    )
                                )
                        }
                        
                        Text("\(Int(score.value * 100))")
                            .font(.system(size: 9, weight: .light).monospacedDigit())
                            .foregroundStyle(sphereColor(score.decayLevel).opacity(0.7))
                        
                        Text(shortLabel(record.date))
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160, alignment: .bottom)
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(sphereColor(0.0).opacity(0.8))
                        .frame(width: 16, height: 4)
                    Text(focusLabel)
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.15))
                        .frame(width: 16, height: 4)
                    Text(distractionLabel)
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                }
                
                Spacer()
            }
        }
    }
    
    func shortLabel(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let d = formatter.date(from: date) {
            let day = DateFormatter()
            day.dateFormat = "EEE"
            return day.string(from: d)
        }
        return String(date.prefix(3))
    }
}

// MARK: - StatCard

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let decay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .light))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.45))
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .thin))
                    .foregroundStyle(sphereColor(decay))
                
                Text(unit)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    StatsView()
        .environmentObject(FocusMonitor())
        .environmentObject(LocalizationManager.shared)
}
