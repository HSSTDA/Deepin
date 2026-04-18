import SwiftUI

// (1) الواجهة الكاملة لشاشة الحظر
struct ShieldView: View {
    
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // خلفية سوداء شفافة
            Color.black.opacity(0.92).ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // (2) الكرة في حالتها الأسوأ — مكتملة التشتت
                ZStack {
                    // Glow خافت جداً
                    Circle()
                        .fill(
                            Color(hue: 0.45, saturation: 0.5, brightness: 0.8)
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .opacity(pulse ? 0.15 : 0.08)
                    
                    // الكرة الأساسية — باهتة ومفرطحة
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hue: 0.45, saturation: 0.5, brightness: 0.75)
                                        .opacity(0.6),
                                    Color(hue: 0.45, saturation: 0.5, brightness: 0.4)
                                        .opacity(0.3)
                                ],
                                center: UnitPoint(x: 0.4, y: 0.4),
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(
                            x: pulse ? 1.04 : 1.0,
                            y: pulse ? 0.97 : 1.0
                        )
                        .offset(y: 12)
                }
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        pulse = true
                    }
                }
                
                Spacer().frame(height: 48)
                
                // (3) النص الرئيسي
                VStack(spacing: 12) {
                    Text("Time's up.")
                        .font(.system(size: 28, weight: .thin))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.85))
                    
                    Text("You've reached your limit for today.\nYour focus is worth protecting.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                
                Spacer()
                
                // (4) معلومة إضافية
                Text("Resets at midnight")
                    .font(.system(size: 11, weight: .light))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.15))
                    .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ShieldView()
}
