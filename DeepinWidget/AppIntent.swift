import AppIntents
import WidgetKit

// نحذف الـ Emoji intent ونضع intent بسيط للمشروع
struct DeepinConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Deepin Focus Widget" }
    static var description: IntentDescription { "Shows your current focus state." }
}
