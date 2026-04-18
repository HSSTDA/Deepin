import SwiftUI

struct DeepSphere: View {
    
    var decayLevel: Double = 0.0
    @State private var isPulsing: Bool = false
    
    var sphereColor: Color {
        Color(
            hue: 0.65 - (decayLevel * 0.2),
            saturation: 0.8 - (decayLevel * 0.3),
            brightness: 0.9
        )
    }
    
    var pulseSpeed: Double {
        switch decayLevel {
        case 0.0..<0.3:  return 2.5   // هادئ وبطيء — تركيز عميق
        case 0.3..<0.6:  return 1.5   // متوسط — بدأ الانجراف
        case 0.6..<0.85: return 0.8   // سريع — خطر
        default:         return 0.4   // سريع جداً — تجاوز الحد
        }
    }
    
    var pulseScale: Double {
        isPulsing ? 1.06 + (decayLevel * 0.04) : 1.0
    }
    
    // (1) الكرة تنكمش قليلاً — مثل كرة فقدت ضغطها
    var sphereScale: Double {
        1.0 - (decayLevel * 0.12)
    }
    
    // (2) الكرة تنزل لأسفل بسبب "الجاذبية" — تفقد ارتفاعها
    var dropOffset: Double {
        decayLevel * 18
    }
    
    var body: some View {
        ZStack {
            
            // الـ Glow يضعف ويتلاشى
            Circle()
                .fill(sphereColor)
                .frame(width: 260, height: 260)
                .blur(radius: 40 + (decayLevel * 20))
                .opacity(0.4 - (decayLevel * 0.3))  // (3) يختفي تدريجياً
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .offset(y: dropOffset)
            
            // الكرة الأساسية
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            sphereColor.opacity(0.95),
                            sphereColor.opacity(0.4 + (decayLevel * 0.3)),
                        ],
                        center: UnitPoint(
                            x: 0.35,
                            y: 0.3 + (decayLevel * 0.2)  // (4) مصدر الضوء ينزل
                        ),
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(sphereScale * pulseScale)
                .offset(y: dropOffset)
            
            // الـ Highlight يختفي تماماً مع التشتت
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.35 - (decayLevel * 0.35)), // (5) يختفي
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 220, height: 220)
                .blur(radius: decayLevel * 6)
                .scaleEffect(sphereScale * pulseScale)
                .offset(y: dropOffset)
        }
        .onAppear { startPulsing() }
        .onChange(of: decayLevel) {
            isPulsing = false
            startPulsing()
        }
    }
    
    func startPulsing() {
        withAnimation(
            .easeInOut(duration: pulseSpeed)
            .repeatForever(autoreverses: true)
        ) {
            isPulsing = true
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 50) {
            DeepSphere(decayLevel: 0.0)
            DeepSphere(decayLevel: 0.5)
            DeepSphere(decayLevel: 1.0)
        }
    }
}
