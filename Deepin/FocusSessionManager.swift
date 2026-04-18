import SwiftUI
import Combine
import ActivityKit

@MainActor
class FocusSessionManager: ObservableObject {
    
    @Published var isRunning: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var completedSessions: [FocusSession] = []
    
    private var startTime: Date?
    private var timer: AnyCancellable?
    
    // (1) نحتفظ بمرجع الـ Live Activity لتحديثها لاحقاً
    private var liveActivity: Activity<DeepinActivityAttributes>?
    
    var totalFocusMinutes: Int {
        completedSessions.map(\.minutes).reduce(0, +)
    }
    
    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    // MARK: - Start
    
    func start(distractionMinutes: Int, limitMinutes: Int) {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date()
        elapsedSeconds = 0
        
        // (2) نشغل الـ Timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsedSeconds += 1
                
                // (3) كل 60 ثانية نحدث الـ Live Activity
                if self.elapsedSeconds % 60 == 0 {
                    Task {
                        await self.updateLiveActivity(
                            distractionMinutes: distractionMinutes,
                            limitMinutes: limitMinutes
                        )
                    }
                }
            }
        
        // (4) نشغل الـ Live Activity عند البداية
        Task {
            await startLiveActivity(
                distractionMinutes: distractionMinutes,
                limitMinutes: limitMinutes
            )
        }
    }
    
    // MARK: - Stop
    
    func stop() {
        guard isRunning, let start = startTime else { return }
        isRunning = false
        timer?.cancel()
        
        let session = FocusSession(startTime: start, endTime: Date())
        
        if session.minutes >= 1 {
            completedSessions.append(session)
            SharedDataManager.saveFocusMinutes(totalFocusMinutes)
        }
        
        startTime = nil
        
        // (5) نوقف الـ Live Activity
        Task { await endLiveActivity() }
    }
    
    // MARK: - Live Activity
    
    // (6) تشغيل الـ Live Activity
    private func startLiveActivity(distractionMinutes: Int, limitMinutes: Int) async {
        
        // تأكد أن الجهاز يدعم Live Activities
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = DeepinActivityAttributes(startTime: Date())
        
        let state = DeepinActivityAttributes.ContentState(
            decayLevel: computeDecay(
                focusMinutes: totalFocusMinutes,
                distractionMinutes: distractionMinutes,
                limitMinutes: limitMinutes
            ),
            minutesUsed: distractionMinutes,
            minutesLimit: limitMinutes
        )
        
        do {
            // (7) نطلب من النظام تشغيل الـ Activity
            liveActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil  // بدون push — نحدث يدوياً
            )
        } catch {
            print("Live Activity failed: \(error)")
        }
    }
    
    // (8) تحديث الـ Live Activity كل دقيقة
    private func updateLiveActivity(distractionMinutes: Int, limitMinutes: Int) async {
        guard let activity = liveActivity else { return }
        
        let focusNow = totalFocusMinutes + (elapsedSeconds / 60)
        
        let newState = DeepinActivityAttributes.ContentState(
            decayLevel: computeDecay(
                focusMinutes: focusNow,
                distractionMinutes: distractionMinutes,
                limitMinutes: limitMinutes
            ),
            minutesUsed: distractionMinutes,
            minutesLimit: limitMinutes
        )
        
        await activity.update(
            .init(state: newState, staleDate: nil)
        )
    }
    
    // (9) إنهاء الـ Live Activity
    private func endLiveActivity() async {
        await liveActivity?.end(nil, dismissalPolicy: .immediate)
        liveActivity = nil
    }
    
    // (10) نفس منطق DepthScore لكن هنا للـ Live Activity
    private func computeDecay(
        focusMinutes: Int,
        distractionMinutes: Int,
        limitMinutes: Int
    ) -> Double {
        let score = DepthScore(
            focusMinutes: focusMinutes,
            distractionMinutes: distractionMinutes
        )
        return score.decayLevel
    }
}

// MARK: - FocusSession Model

struct FocusSession: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var minutes: Int {
        Int(duration / 60)
    }
}
