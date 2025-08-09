//
//  HoursBackReport.swift
//  bonsai
//
//  Created by Brayden O on 2025-05-11.
//

import DeviceActivity
import SwiftUI

private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: BONSAI_GROUP_NAME)
}

extension DeviceActivityReport.Context {
    static let hoursBack = Self("hours_back")
}

// ******
// NOTE: This is not being used right now and is unfinished. I will finish it if i can figure out a way - Brayden
struct HoursBackReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .hoursBack
    let content: (String) -> HoursBackView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        //if let previousHoursPerDay = sharedDefaults!.data
        
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
    
    //func
}

struct HoursBackView: View {
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

