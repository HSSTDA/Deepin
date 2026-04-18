import SwiftUI
import WidgetKit
import FamilyControls

struct ContentView: View {
    
    @EnvironmentObject var focusMonitor: FocusMonitor
    @EnvironmentObject var monitoringManager: MonitoringManager
    @EnvironmentObject var localization: LocalizationManager
    @State private var showFocusSession = false
    
    var s: Strings { Strings(lang: localization.language) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    
                    // الهيدر
                    VStack(spacing: 6) {
                        Text("Deepin")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(8)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Text(Date(), format: .dateTime.weekday(.wide).day().month())
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.top, 16)
                    
                    // الكرة
                    DeepSphere(decayLevel: focusMonitor.decayLevel)
                    
                    // الحالة
                    VStack(spacing: 8) {
                        Text(s.focusLabel(for: focusMonitor.decayLevel))
                            .font(.system(size: 14, weight: .light))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.85))
                        
                        Text("\(focusMonitor.totalMinutesToday) / \(focusMonitor.dailyLimitMinutes) min today")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    
                    // زر جلسة التركيز
                    Button {
                        showFocusSession = true
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(
                                    focusMonitor.decayLevel < 0.3
                                    ? Color.green.opacity(0.6)
                                    : Color.white.opacity(0.2)
                                )
                                .frame(width: 6, height: 6)
                            
                            Text(s.startFocusSession)
                                .font(.system(size: 12, weight: .light))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .sheet(isPresented: $showFocusSession) {
                        FocusSessionView()
                            .environmentObject(focusMonitor)
                            .environmentObject(localization)
                    }
                    
                    // Progress Bar
                    DecayProgressBar(
                        decayLevel: focusMonitor.decayLevel,
                        minutesUsed: focusMonitor.totalMinutesToday,
                        minutesLimit: focusMonitor.dailyLimitMinutes
                    )
                    
                    // حالة المراقبة
                    HStack(spacing: 8) {
                        Circle()
                            .fill(monitoringManager.selectedApps.applicationTokens.isEmpty
                                  ? .red.opacity(0.5)
                                  : .green.opacity(0.5))
                            .frame(width: 6, height: 6)
                        
                        Text(monitoringManager.selectedApps.applicationTokens.isEmpty
                             ? s.noAppsMonitored
                             : "\(monitoringManager.selectedApps.applicationTokens.count) apps monitored")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                
                // أزرار التنقل السفلية
                VStack {
                    Spacer()
                    
                    HStack(spacing: 48) {
                        NavigationLink(s.stats) {
                            StatsView()
                                .environmentObject(focusMonitor)
                                .environmentObject(localization)
                        }
                        .font(.system(size: 12, weight: .light))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.4))
                        
                        NavigationLink(s.setup) {
                            AppPickerView()
                                .environmentObject(monitoringManager)
                                .environmentObject(localization)
                        }
                        .font(.system(size: 12, weight: .light))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.4))
                        
                        // (1) زر تغيير اللغة
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                localization.toggle()
                            }
                        } label: {
                            Text(localization.isArabic ? "EN" : "ع")
                                .font(.system(size: 12, weight: .light))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            // (2) اتجاه الواجهة يتغير مع اللغة
            .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FocusMonitor())
        .environmentObject(MonitoringManager.shared)
        .environmentObject(LocalizationManager.shared)
}
