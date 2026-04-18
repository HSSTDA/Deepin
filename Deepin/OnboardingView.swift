import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("hasCompletedOnboarding") var hasCompleted = false
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var currentPage = 0
    @State private var sphereDecay = 0.0
    @State private var showGoalsSetup = false
    @EnvironmentObject var monitoringManager: MonitoringManager
    
    let decayValues: [Double] = [0.0, 0.6, 0.0]
    
    var s: Strings { Strings(lang: localization.language) }
    
    // نقرأ الصفحات من الـ Strings
    var pages: [(title: String, subtitle: String)] {
        s.onboarding
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // زر تغيير اللغة في الأعلى
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            localization.toggle()
                        }
                    } label: {
                        Text(localization.isArabic ? "EN" : "ع")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(16)
                    }
                }
                Spacer()
            }
            
            
            VStack(spacing: 0) {
                
                Spacer()
                
                DeepSphere(decayLevel: sphereDecay)
                    .animation(.easeInOut(duration: 1.4), value: sphereDecay)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text(pages[currentPage].title)
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    Text(pages[currentPage].subtitle)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // مؤشر الصفحات
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(index == currentPage ? 0.6 : 0.15))
                            .frame(width: index == currentPage ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 48)
                
                // الزر
                Button {
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                        sphereDecay = decayValues[currentPage]
                    } else {
                        showGoalsSetup = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1
                         ? (localization.isArabic ? "التالي" : "Continue")
                         : (localization.isArabic ? "ابدأ" : "Get Started"))
                        .font(.system(size: 15, weight: .light))
                        .tracking(2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
            }
        }
        .fullScreenCover(isPresented: $showGoalsSetup) {
            GoalsSetupView()
                .environmentObject(localization)
                .environmentObject(monitoringManager)
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
        
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager.shared)
}
