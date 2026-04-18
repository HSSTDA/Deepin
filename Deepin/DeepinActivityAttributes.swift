import ActivityKit
import Foundation

struct DeepinActivityAttributes: ActivityAttributes {
    
    struct ContentState: Codable, Hashable {
        var decayLevel: Double
        var minutesUsed: Int
        var minutesLimit: Int
        
        var minutesRemaining: Int {
            max(minutesLimit - minutesUsed, 0)
        }
    }
    
    var startTime: Date
}
