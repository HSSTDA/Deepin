import SwiftUI

struct DecayProgressBar: View {
    
    let decayLevel: Double      // 0.0 → 1.0
    let minutesUsed: Int
    let minutesLimit: Int
    
    @State private var animated = false
    @State private var shimmer = false
    
    // (1) لون يتغير مع الـ decay
    var barColor: Color { sphereColor(decayLevel) }
    
    // (2) نسبة الامتلاء
    var progress: Double { min(decayLevel, 1.0) }
    
    var body: some View {
        VStack(spacing: 10) {
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    
                    // الخلفية
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.05))
                        .frame(height: 6)
                    
                    // (3) الشريط الرئيسي
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    barColor.opacity(0.9),
                                    barColor.opacity(0.5)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: animated
                                ? geo.size.width * progress
                                : 0,
                            height: 6
                        )
                        .animation(
                            .easeOut(duration: 1.2),
                            value: animated
                        )
                        .animation(
                            .easeInOut(duration: 1.5),
                            value: progress
                        )
                    
                    // (4) Shimmer — بريق يتحرك على الشريط
                    if progress > 0 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.25),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * progress,
                                height: 6
                            )
                            .offset(x: shimmer
                                ? geo.size.width * progress
                                : -geo.size.width * progress
                            )
                            .animation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: false),
                                value: shimmer
                            )
                            .clipped()
                    }
                    
                    // (5) نقطة على رأس الشريط
                    if progress > 0.02 {
                        Circle()
                            .fill(barColor)
                            .frame(width: 10, height: 10)
                            .shadow(color: barColor.opacity(0.8), radius: 4)
                            .offset(
                                x: (geo.size.width * progress) - 5
                            )
                            .animation(
                                .easeInOut(duration: 1.5),
                                value: progress
                            )
                    }
                }
            }
            .frame(height: 10)
            
            // (6) الأرقام
            HStack {
                Text("\(minutesUsed) min used")
                    .font(.system(size: 10, weight: .light).monospacedDigit())
                    .foregroundStyle(barColor.opacity(0.7))
                
                Spacer()
                
                Text("\(minutesLimit - minutesUsed) remaining")
                    .font(.system(size: 10, weight: .light).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.2))
            }
        }
        .padding(.horizontal, 40)
        .onAppear {
            animated = true
            shimmer = true
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 40) {
            DecayProgressBar(decayLevel: 0.2, minutesUsed: 36, minutesLimit: 180)
            DecayProgressBar(decayLevel: 0.5, minutesUsed: 90, minutesLimit: 180)
            DecayProgressBar(decayLevel: 0.9, minutesUsed: 162, minutesLimit: 180)
        }
    }
}
