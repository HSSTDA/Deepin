import SwiftUI
import FamilyControls
import WidgetKit

struct AppPickerView: View {
    
    @EnvironmentObject var monitor: MonitoringManager
    @State private var showPicker = false
    @Environment(\.dismiss) var dismiss  // (1)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                Text("Monitor")
                    .font(.system(size: 16, weight: .light))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.4))
                
                // عدد التطبيقات
                VStack(spacing: 8) {
                    Text("\(monitor.selectedApps.applicationTokens.count)")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("apps selected")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                // زر الاختيار
                Button {
                    showPicker = true
                } label: {
                    Text("Choose Apps")
                        .font(.system(size: 14, weight: .light))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // زر تشغيل المراقبة
                if !monitor.selectedApps.applicationTokens.isEmpty {
                    Button {
                        monitor.startMonitoring()
                        // (2) نحدث الـ Widget بعد تغيير الإعدادات
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    } label: {
                        Text("Start Monitoring")
                            .font(.system(size: 14, weight: .light))
                            .tracking(2)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
        }
        .familyActivityPicker(
            isPresented: $showPicker,
            selection: $monitor.selectedApps
        )
    }
}
