import SwiftUI

struct FocusSessionView: View {
    
    @EnvironmentObject var focusMonitor: FocusMonitor
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var session = FocusSessionManager()
    @Environment(\.dismiss) var dismiss
    
    var s: Strings { Strings(lang: localization.language) }
    
    var score: DepthScore {
        DepthScore(
            focusMinutes: session.totalFocusMinutes,
            distractionMinutes: focusMonitor.totalMinutesToday
        )
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack {
                    Button {
                        if session.isRunning { session.stop() }
                        dismiss()
                    } label: {
                        Text(s.done)
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    
                    Spacer()
                    
                    Text(s.focus)
                        .font(.system(size: 14, weight: .light))
                        .tracking(6)
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text(s.done).opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - الكرة + المؤقت
                ZStack {
                    DeepSphere(decayLevel: score.decayLevel)
                    
                    if session.isRunning {
                        Text(session.elapsedFormatted)
                            .font(.system(size: 22, weight: .thin).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                
                Spacer().frame(height: 32)
                
                // MARK: - الحالة
                VStack(spacing: 8) {
                    Text(s.focusLabel(for: score.decayLevel))
                        .font(.system(size: 18, weight: .light))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.85))
                        .animation(.easeInOut(duration: 0.5), value: score.decayLevel)
                    
                    Text(score.insight)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: score.insight)
                }
                .padding(.horizontal, 40)
                
                Spacer().frame(height: 40)
                
                // MARK: - بطاقة المقارنة
                ComparisonCard(
                    focusMinutes: session.totalFocusMinutes,
                    distractionMinutes: focusMonitor.totalMinutesToday,
                    score: score.value,
                    focusLabel: s.focus,
                    distractionLabel: s.distraction,
                    depthScoreLabel: s.depthScore
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // MARK: - زر التشغيل
                VStack(spacing: 12) {
                    SessionButton(isRunning: session.isRunning) {
                        if session.isRunning {
                            session.stop()
                        } else {
                            session.start(
                                distractionMinutes: focusMonitor.totalMinutesToday,
                                limitMinutes: focusMonitor.dailyLimitMinutes
                            )
                        }
                    }
                    
                    Text(session.isRunning ? s.tapToEnd : s.tapToStart)
                        .font(.system(size: 11, weight: .light))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.25))
                }
                .padding(.bottom, 56)
            }
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
    }
}

// MARK: - ComparisonCard

struct ComparisonCard: View {
    let focusMinutes: Int
    let distractionMinutes: Int
    let score: Double
    let focusLabel: String
    let distractionLabel: String
    let depthScoreLabel: String
    
    var focusRatio: Double {
        let total = Double(focusMinutes + distractionMinutes)
        guard total > 0 else { return 0 }
        return Double(focusMinutes) / total
    }
    
    var scoreColor: Color { sphereColor(1.0 - score) }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // شريط المقارنة
            VStack(spacing: 8) {
                HStack {
                    Text(focusLabel)
                        .font(.system(size: 11, weight: .light))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text(distractionLabel)
                        .font(.system(size: 11, weight: .light))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        scoreColor.opacity(0.9),
                                        scoreColor.opacity(0.5)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * focusRatio,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 1.0), value: focusRatio)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(focusMinutes)m")
                        .font(.system(size: 13, weight: .light).monospacedDigit())
                        .foregroundStyle(scoreColor)
                    
                    Spacer()
                    
                    Text("\(distractionMinutes)m")
                        .font(.system(size: 13, weight: .light).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            
            Divider()
                .background(.white.opacity(0.08))
            
            // Depth Score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(depthScoreLabel.uppercased())
                        .font(.system(size: 9, weight: .light))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.4))
                    
                    if distractionMinutes >= 180 {
                        Text("⚠︎ Distraction limit reached")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
                
                Spacer()
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(score * 100))")
                        .font(.system(size: 32, weight: .thin).monospacedDigit())
                        .foregroundStyle(scoreColor)
                    
                    Text("%")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
        }
        .padding(20)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - SessionButton

struct SessionButton: View {
    let isRunning: Bool
    let action: () -> Void
    
    @State private var pulse = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 88, height: 88)
                    .scaleEffect(pulse ? 1.15 : 1.0)
                    .opacity(isRunning ? 1 : 0)
                
                Circle()
                    .stroke(.white.opacity(isRunning ? 0.2 : 0.12), lineWidth: 1)
                    .frame(width: 72, height: 72)
                
                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 22, weight: .thin))
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            ) { pulse = true }
        }
        .onChange(of: isRunning) {
            pulse = false
            withAnimation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            ) { pulse = true }
        }
    }
}

#Preview {
    FocusSessionView()
        .environmentObject(FocusMonitor())
        .environmentObject(LocalizationManager.shared)
}
