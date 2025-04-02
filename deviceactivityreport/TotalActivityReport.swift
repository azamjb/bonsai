import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("total_activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    let content: (String) -> TotalActivityView 

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll

        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })

        guard let formattedTime = formatter.string(from: totalActivityDuration) else {
            return "No activity data"
        }

        return formattedTime  
    }
}
