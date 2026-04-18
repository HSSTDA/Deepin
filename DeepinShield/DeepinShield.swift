import ManagedSettingsUI
import ManagedSettings
internal import UIKit

// ShieldConfigurationDataSource is an NSObject subclass — must be `class` with `override`
class DeepinShieldConfiguration: ShieldConfigurationDataSource {

    override func configuration(
        shielding application: Application
    ) -> ShieldConfiguration {

        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: .black,
            icon: nil,
            title: ShieldConfiguration.Label(
                text: "",
                color: .clear
            ),
            subtitle: ShieldConfiguration.Label(
                text: "",
                color: .clear
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "I need more time",
                color: .white.withAlphaComponent(0.6)
            ),
            primaryButtonBackgroundColor: .white.withAlphaComponent(0.08),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Go Back",
                color: .white.withAlphaComponent(0.3)
            )
        )
    }
}
