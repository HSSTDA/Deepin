import WidgetKit
import SwiftUI

@main
struct DeepinWidgetBundle: WidgetBundle {
    var body: some Widget {
        DeepinWidget()
        DeepinWidgetControl()
        DeepinLiveActivity()      // ← الاسم الجديد
    }
}
