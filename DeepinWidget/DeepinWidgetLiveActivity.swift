import ActivityKit
import WidgetKit
import SwiftUI



// (4) الواجهة الفعلية للـ Live Activity
struct DeepinLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeepinActivityAttributes.self) { context in
            
            // (5) شريط الإشعارات (Lock Screen / Banner)
            DeepinLiveBanner(state: context.state)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                // (6) الحالة الموسعة — عند الضغط
                DynamicIslandExpandedRegion(.center) {
                    DeepinExpandedIsland(state: context.state)
                }
            } compactLeading: {
                // (7) الجانب الأيسر المضغوط
                MiniSphere(decayLevel: context.state.decayLevel, size: 22)
                
            } compactTrailing: {
                // (8) الجانب الأيمن — الوقت المتبقي
                Text("\(context.state.minutesRemaining)m")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(sphereColor(context.state.decayLevel))
                
            } minimal: {
                // (9) أصغر حجم — نقطة ملونة فقط
                MiniSphere(decayLevel: context.state.decayLevel, size: 16)
            }
        }
    }
}

// (10) شريط الإشعار الكامل
struct DeepinLiveBanner: View {
    let state: DeepinActivityAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 16) {
            
            MiniSphere(decayLevel: state.decayLevel, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Deepin")
                    .font(.system(size: 11, weight: .light))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.35))
                
                Text("\(state.minutesRemaining) minutes remaining")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(.white.opacity(0.85))
            }
            
            Spacer()
            
            // شريط تقدم دائري
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 2)
                
                Circle()
                    .trim(from: 0, to: state.decayLevel) // (11) يمتلئ مع التشتت
                    .stroke(
                        sphereColor(state.decayLevel),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 32, height: 32)
        }
        .padding(16)
        .background(.black)
        .activityBackgroundTint(.black)
    }
}

// (12) الـ Dynamic Island الموسع
struct DeepinExpandedIsland: View {
    let state: DeepinActivityAttributes.ContentState
    
    var statusText: String {
        state.minutesRemaining <= 5 ? "Almost out of time" : "Stay focused"
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(statusText)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.6))
            
            Text("\(state.minutesUsed) / \(state.minutesLimit) min")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

// (13) كرة مصغرة للـ Dynamic Island
struct MiniSphere: View {
    let decayLevel: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(sphereColor(decayLevel))
                .frame(width: size, height: size)
                .blur(radius: size * 0.2)
                .opacity(0.5)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            sphereColor(decayLevel).opacity(0.95),
                            sphereColor(decayLevel).opacity(0.4)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
        }
    }
}

// (14) دالة مشتركة للون — بدل تكرارها في كل مكان
func sphereColor(_ decay: Double) -> Color {
    Color(
        hue: 0.65 - (decay * 0.2),
        saturation: 0.8 - (decay * 0.3),
        brightness: 0.9
    )
}

// Preview
#Preview("Live Activity", as: .content, using: DeepinActivityAttributes(startTime: .now)) {
    DeepinLiveActivity()
} contentStates: {
    DeepinActivityAttributes.ContentState(
        decayLevel: 0.3,
        minutesUsed: 45,
        minutesLimit: 180
    )
    DeepinActivityAttributes.ContentState(
        decayLevel: 0.85,
        minutesUsed: 160,
        minutesLimit: 180
      )
}
