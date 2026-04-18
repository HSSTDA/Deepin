import SwiftUI
import FamilyControls

struct GoalsSetupView: View {
    
    @EnvironmentObject var localization: LocalizationManager
    @AppStorage("hasCompletedOnboarding") var hasCompleted = false
    @AppStorage("focusGoalMinutes") var focusGoalMinutes: Int = 90
    @AppStorage("distractionLimitMinutes") var distractionLimitMinutes: Int = 45
    
    @State private var currentStep = 0
    @State private var showAppPicker = false
    @EnvironmentObject var monitoringManager: MonitoringManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(index <= currentStep ? 0.6 : 0.15))
                            .frame(width: index == currentStep ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: - المحتوى
                switch currentStep {
                case 0: focusGoalStep
                case 1: distractionLimitStep
                case 2: appPickerStep
                default: EmptyView()
                }
                
                Spacer()
                
                // MARK: - الزر
                Button {
                    if currentStep < 2 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep += 1
                        }
                    } else {
                        monitoringManager.startMonitoring()
                        hasCompleted = true
                    }
                } label: {
                    Text(currentStep < 2
                         ? (localization.isArabic ? "التالي" : "Continue")
                         : (localization.isArabic ? "ابدأ" : "Let's go"))
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
                .opacity(
                    currentStep == 2 && monitoringManager.selectedApps.applicationTokens.isEmpty
                    ? 0.4 : 1.0
                )
                .disabled(
                    currentStep == 2 && monitoringManager.selectedApps.applicationTokens.isEmpty
                )
            }
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
    }
    
    // MARK: - Step 1: هدف التركيز
    
    var focusGoalStep: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 12) {
                Text(localization.isArabic ? "هدف التركيز" : "Focus Goal")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(localization.isArabic
                     ? "كم دقيقة تريد أن تركز يومياً؟"
                     : "How many minutes do you want to focus daily?")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(focusGoalMinutes)")
                        .font(.system(size: 64, weight: .ultraLight).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.9))
                        .contentTransition(.numericText())
                    
                    Text(localization.isArabic ? "د" : "min")
                        .font(.system(size: 18, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Text(focusGoalMessage)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(focusGoalColor)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: focusGoalMinutes)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { Double(focusGoalMinutes) },
                        set: { focusGoalMinutes = Int($0) }
                    ),
                    in: 15...960,
                    step: 15
                )
                .tint(.white.opacity(0.4))
                .padding(.horizontal, 32)
                
                HStack {
                    Text("15m")
                    Spacer()
                    Text("8h")
                    Spacer()
                    Text("16h")
                }
                .font(.system(size: 10, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.2))
                .padding(.horizontal, 36)
            }
        }
    }
    
    // MARK: - Step 2: حد الاستخدام
    
    var distractionLimitStep: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 12) {
                Text(localization.isArabic ? "حد التشتت" : "Distraction Limit")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(localization.isArabic
                     ? "ما أقصى وقت تسمح لنفسك فيه بالتشتت؟"
                     : "What's your daily limit for distracting apps?")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(distractionLimitMinutes)")
                        .font(.system(size: 64, weight: .ultraLight).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.9))
                        .contentTransition(.numericText())
                    
                    Text(localization.isArabic ? "د" : "min")
                        .font(.system(size: 18, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Text(distractionLimitMessage)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(distractionLimitColor)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: distractionLimitMinutes)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { Double(distractionLimitMinutes) },
                        set: { newValue in
                            let oldLimit = distractionLimitMinutes
                            let newLimit = Int(newValue)
                            
                            // تنبيه لو رفع الحد بشكل كبير
                            if newLimit > oldLimit + 30 {
                                NotificationManager.shared.scheduleGoalChangedWarning(
                                    oldLimit: oldLimit,
                                    newLimit: newLimit,
                                    isArabic: localization.isArabic
                                )
                            }
                            
                            distractionLimitMinutes = newLimit
                        }
                    ),
                    in: 5...720,
                    step: 5
                )
                .tint(.white.opacity(0.4))
                .padding(.horizontal, 32)
                
                HStack {
                    Text("5m")
                    Spacer()
                    Text("3h")
                    Spacer()
                    Text("12h")
                }
                .font(.system(size: 10, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.2))
                .padding(.horizontal, 36)
            }
        }
    }
    
    // MARK: - Step 3: اختيار التطبيقات
    
    var appPickerStep: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 12) {
                Text(localization.isArabic ? "التطبيقات المشتتة" : "Distracting Apps")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(localization.isArabic
                     ? "أي التطبيقات تسرق وقتك؟"
                     : "Which apps steal your focus?")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 4) {
                Text("\(monitoringManager.selectedApps.applicationTokens.count)")
                    .font(.system(size: 64, weight: .ultraLight).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.9))
                    .contentTransition(.numericText())
                
                Text(localization.isArabic ? "تطبيقات محددة" : "apps selected")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.3))
            }
            
            Button {
                showAppPicker = true
            } label: {
                Text(localization.isArabic ? "اختر التطبيقات" : "Choose Apps")
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
        }
        .familyActivityPicker(
            isPresented: $showAppPicker,
            selection: $monitoringManager.selectedApps
        )
    }
    
    // MARK: - رسائل التنبيه — التركيز
    
    var focusGoalMessage: String {
        switch focusGoalMinutes {
        case 0..<30:    return localization.isArabic ? "وقت قصير، لكن البداية تكفي" : "Short, but a start is enough"
        case 30..<90:   return localization.isArabic ? "هدف واقعي وقابل للتحقيق ✓" : "Realistic and achievable ✓"
        case 90..<180:  return localization.isArabic ? "طموح وممتاز، أنت جاد" : "Ambitious — you mean business"
        case 180..<300: return localization.isArabic ? "تحدٍّ حقيقي — تذكر الاستراحات" : "Real challenge — remember to breathe"
        case 300..<480: return localization.isArabic ? "هذا يحتاج إرادة استثنائية" : "This takes exceptional discipline"
        case 480..<600: return localization.isArabic ? "٨+ ساعات — جسمك يحتاج راحة أيضاً" : "8h+ — your body needs rest too"
        case 600..<720: return localization.isArabic ? "تجاوزت حدود التركيز الطبيعي" : "Beyond natural focus limits"
        default:        return localization.isArabic ? "هذا يؤثر على جودة تركيزك، لا كميته" : "This affects quality, not just quantity"
        }
    }
    
    var focusGoalColor: Color {
        switch focusGoalMinutes {
        case 0..<30:    return .white.opacity(0.3)
        case 30..<300:  return .green.opacity(0.6)
        case 300..<480: return .orange.opacity(0.6)
        default:        return .red.opacity(0.5)
        }
    }
    
    // MARK: - رسائل التنبيه — التشتت
    
    var distractionLimitMessage: String {
        switch distractionLimitMinutes {
        case 0..<15:    return localization.isArabic ? "صارم جداً — لكن ممكن" : "Very strict — but possible"
        case 15..<60:   return localization.isArabic ? "توازن ممتاز ✓" : "Excellent balance ✓"
        case 60..<120:  return localization.isArabic ? "معقول، راقب نفسك" : "Reasonable — stay aware"
        case 120..<180: return localization.isArabic ? "بدأ يثقل — الكرة ستلاحظ" : "Getting heavy — your sphere will notice"
        case 180:       return localization.isArabic ? "٣ ساعات — الحد الأقصى للتوازن" : "3 hours — the edge of balance"
        case 181..<360: return localization.isArabic ? "ربع يومك للتشتت — كثير" : "A quarter of your day — that's a lot"
        case 360..<480: return localization.isArabic ? "نصف يوم عمل كامل في التشتت" : "Half a workday lost to distraction"
        default:        return localization.isArabic ? "أكثر من ٦ ساعات — أنت تعرف الجواب" : "6h+ — you know the answer"
        }
    }
    
    var distractionLimitColor: Color {
        switch distractionLimitMinutes {
        case 0..<15:    return .white.opacity(0.3)
        case 15..<120:  return .green.opacity(0.6)
        case 120..<180: return .orange.opacity(0.4)
        case 180:       return .green.opacity(0.5)
        case 181..<360: return .orange.opacity(0.6)
        default:        return .red.opacity(0.5)
        }
    }
}

#Preview {
    GoalsSetupView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(MonitoringManager.shared)
}
