import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("total_activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    
    typealias Content = TotalActivityView
    typealias Configuration = String

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        formatter.zeroFormattingBehavior = .dropAll

        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })

        guard let formattedTime = formatter.string(from: totalActivityDuration) else {
            return "No activity data"
        }

        return formattedTime  
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            TotalActivityView(totalActivity: configuration)
        }
    }
}

struct TotalActivityView: View {
    let context: DeviceActivityReport.Context = .totalActivity
    
    let totalActivity: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                formatTotalActivityText(totalActivity)
            }
        }
    }

    func formatTotalActivityText(_ text: String) -> some View {
        let components = text.split(separator: " ")

        return HStack(spacing: 12) {
            ForEach(components, id: \.self) { component in
                if let numberPart = component.first(where: { $0.isNumber }) {
                    let unitPart = component.drop { $0.isNumber }
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text(String(numberPart))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(String(unitPart))
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

}
