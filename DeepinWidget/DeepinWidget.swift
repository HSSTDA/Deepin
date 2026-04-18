import WidgetKit
import SwiftUI

// (1) Provider — مسؤول عن توفير البيانات للـ Widget
struct DeepinProvider: TimelineProvider {
    
    // (2) Placeholder — يظهر لما الـ Widget لسه يحمل
    func placeholder(in context: Context) -> DeepinEntry {
        DeepinEntry(date: .now, decayLevel: 0.0)
    }
    
    // (3) Snapshot — معاينة سريعة في Gallery
    func getSnapshot(
        in context: Context,
        completion: @escaping (DeepinEntry) -> Void
    ) {
        let entry = DeepinEntry(
            date: .now,
            decayLevel: SharedDataManager.loadDecay()
        )
        completion(entry)
    }
    
    // (4) Timeline — جدول تحديثات الـ Widget
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<DeepinEntry>) -> Void
    ) {
        // نقرأ آخر قيمة محفوظة من الـ Shared Store
        let currentDecay = SharedDataManager.loadDecay()
        
        let entry = DeepinEntry(
            date: .now,
            decayLevel: currentDecay
        )
        
        // (5) نطلب من iOS تحديث الـ Widget بعد 15 دقيقة
        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 15,
            to: .now
        ) ?? Date().addingTimeInterval(900)
        
        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)  // (6)
        )
        
        completion(timeline)
    }
}

// (7) Entry — "لقطة" من البيانات في لحظة معينة
struct DeepinEntry: TimelineEntry {
    let date: Date
    let decayLevel: Double
}

// (8) واجهة الـ Widget نفسها
struct DeepinWidgetView: View {
    var entry: DeepinEntry
    
    // (9) حجم الـ Widget الحالي — يتغير حسب ما اختار المستخدم
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color.black
            
            switch family {
                
            case .systemSmall:      // الحجم الصغير
                SmallWidgetView(decayLevel: entry.decayLevel)
                
            case .systemMedium:     // الحجم المتوسط
                MediumWidgetView(decayLevel: entry.decayLevel)
                
            default:
                SmallWidgetView(decayLevel: entry.decayLevel)
            }
        }
    }
}

// (10) الحجم الصغير — الكرة فقط
struct SmallWidgetView: View {
    let decayLevel: Double
    
    var sphereColor: Color {
        Color(
            hue: 0.65 - (decayLevel * 0.2),
            saturation: 0.8 - (decayLevel * 0.3),
            brightness: 0.9
        )
    }
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(sphereColor)
                .frame(width: 90, height: 90)
                .blur(radius: 16 + (decayLevel * 10))
                .opacity(0.5)
            
            // الكرة
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            sphereColor.opacity(0.95),
                            sphereColor.opacity(0.4)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: 45
                    )
                )
                .frame(width: 80, height: 80)
        }
    }
}

// (11) الحجم المتوسط — الكرة + معلومات
struct MediumWidgetView: View {
    let decayLevel: Double
    
    var statusText: String {
        switch decayLevel {
        case 0.0..<0.3: return "Deep Focus"
        case 0.3..<0.6: return "Drifting..."
        case 0.6..<0.9: return "Losing Ground"
        default:         return "Distracted"
        }
    }
    
    var body: some View {
        HStack(spacing: 24) {
            
            SmallWidgetView(decayLevel: decayLevel)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Deepin")
                    .font(.system(size: 12, weight: .light))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.3))
                
                Text(statusText)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(.white.opacity(0.8))
                
                // شريط تقدم مرئي
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.1))
                            .frame(height: 2)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.4))
                            .frame(
                                width: geo.size.width * decayLevel,
                                height: 2
                            )
                    }
                }
                .frame(height: 2)
            }
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
    }
}

// (12) تسجيل الـ Widget في النظام
struct DeepinWidget: Widget {
    let kind: String = "DeepinWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: DeepinProvider()
        ) { entry in
            DeepinWidgetView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Deepin")
        .description("Your focus state at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium]) // (13)
    }
}

#Preview(as: .systemSmall) {
    DeepinWidget()
} timeline: {
    DeepinEntry(date: .now, decayLevel: 0.0)
    DeepinEntry(date: .now, decayLevel: 0.7)
}
