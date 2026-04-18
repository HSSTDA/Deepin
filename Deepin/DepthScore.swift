import Foundation

struct DepthScore {
    
    let focusMinutes: Int
    let distractionMinutes: Int
    
    // (1) نقرأ الأهداف الشخصية
    var focusGoal: Int {
        let saved = UserDefaults.standard.integer(forKey: "focusGoalMinutes")
        return saved == 0 ? 90 : saved
    }
    
    var distractionLimit: Int {
        let saved = UserDefaults.standard.integer(forKey: "distractionLimitMinutes")
        return saved == 0 ? 60 : saved
    }
    
    // (2) الحساب الرئيسي
    var value: Double {
        let F = Double(focusMinutes)
        let D = Double(distractionMinutes)
        let focusTarget = Double(focusGoal)
        let distractLimit = Double(distractionLimit)
        
        // Base — نسبة التركيز من الهدف الشخصي
        let focusProgress = min(F / focusTarget, 1.0)
        
        // نسبة التشتت من الحد الشخصي
        let distractionRatio = min(D / distractLimit, 1.0)
        
        // Base Score — التركيز يرفع، التشتت يخفض
        let base = (focusProgress * 0.6) + ((1.0 - distractionRatio) * 0.4)
        
        // (3) Penalty — تجاوز الحد الشخصي
        let penalty: Double = {
            let overLimit = D - distractLimit
            if overLimit <= 0 { return 0 }
            switch overLimit {
            case 0..<30:   return 0.10
            case 30..<60:  return 0.20
            case 60..<120: return 0.35
            default:       return 0.50
            }
        }()
        
        // (4) Bonus — تحقيق هدف التركيز
        let bonus: Double = {
            let progress = F / focusTarget
            switch progress {
            case 1.0...:  return 0.10  // حقق الهدف كاملاً
            case 0.75...: return 0.05  // حقق 75%+
            default:      return 0.0
            }
        }()
        
        return min(max(base - penalty + bonus, 0.0), 1.0)
    }
    
    var decayLevel: Double { 1.0 - value }
    
    var label: String {
        switch value {
        case 0.80...: return "Deep"
        case 0.60..<0.80: return "Focused"
        case 0.40..<0.60: return "Balanced"
        case 0.20..<0.40: return "Drifting"
        default: return "Lost"
        }
    }
    
    // (5) insight يأخذ الأهداف الشخصية بالحسبان
    var insight: String {
        let overLimit = distractionMinutes - distractionLimit
        let focusProgress = Double(focusMinutes) / Double(focusGoal)
        
        if overLimit > 60 {
            return "You're \(overLimit)m over your limit — this affects your score"
        }
        if overLimit > 0 {
            return "Just \(overLimit)m over your limit"
        }
        if focusMinutes == 0 {
            return "No focus session recorded yet"
        }
        if focusProgress >= 1.0 {
            return "Goal achieved — exceptional day"
        }
        if distractionMinutes > focusMinutes * 2 {
            return "Distraction is outpacing focus"
        }
        return "\(focusMinutes)m focused · \(distractionMinutes)m distracted"
    }
}
