
import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return makeShield()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return makeShield()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return makeShield()
    }

    private func makeShield() -> ShieldConfiguration {
        let sharedDefaults = UserDefaults(suiteName: BONSAI_GROUP_NAME)
        let subtitleText = sharedDefaults?.string(forKey: "shieldMessage") ?? "Time limit resets at midnight"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: .black,
            icon: UIImage(named: "tiger"),
            title: ShieldConfiguration.Label(
                text: "Boundary Reached",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: .lightGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Ask for More Time",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(hex: "#dd9539"),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Stick to Goal",
                color: .white
            )
        )
    }
}


extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1.0

        switch hexFormatted.count {
        case 6: // RRGGBB
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        case 8: // RRGGBBAA
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgbValue & 0x000000FF) / 255.0

        default:
            print("❌ Invalid hex code: \(hex)")
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
