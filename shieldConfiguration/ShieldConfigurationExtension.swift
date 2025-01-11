import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    let bonsaiShield = ShieldConfiguration(
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
            text: "Keep going strong",
            color: .white
        ),
        primaryButtonBackgroundColor: .systemGray,
        secondaryButtonLabel: ShieldConfiguration.Label(
            text: "Give in",
            color: .white
        )
    )

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return self.bonsaiShield
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return self.bonsaiShield
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return self.bonsaiShield
    }
}
