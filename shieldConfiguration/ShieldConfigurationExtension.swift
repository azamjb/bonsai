import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        var config = ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: UIColor.green.withAlphaComponent(0.55),
            icon: UIImage(systemName: "tree.fill"),
            title: ShieldConfiguration.Label(
                text: "Time Limit Reached",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Bonsai has limited your screen time for today",
                color: .lightGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGray,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Extend",
                color: .white
            )
        )

        return config
    }
}
