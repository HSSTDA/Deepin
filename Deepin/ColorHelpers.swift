import SwiftUI

func sphereColor(_ decay: Double) -> Color {
    Color(
        hue: 0.65 - (decay * 0.45),
        saturation: 0.6 + (decay * 0.3),
        brightness: 0.9 - (decay * 0.2)
    )
}
