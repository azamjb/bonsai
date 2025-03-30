//
//  AppReport.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-26.
//

import _DeviceActivity_SwiftUI
import ManagedSettings
import Foundation
import SwiftUICore

// MARK: - Define Custom Context for Pill Bar Report
extension DeviceActivityReport.Context {
    static let appReport = Self("app_report")
}

struct AppReport: Identifiable {
    var id: UUID = UUID()
    var appToken: ApplicationToken
    var timeSpent: TimeInterval
}

struct AppReportConfiguration {
    let appReports: [AppReport]
}

struct TopAppsView: View {
    let configuration: AppReportConfiguration

    /// Format seconds as "Hh Mm"
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var body: some View {
        VStack {
        }
    }
}

struct TopAppsReport: DeviceActivityReportScene {
    var content: (AppReportConfiguration) -> TopAppsView
 
    typealias Configuration = AppReportConfiguration
 
    typealias Content = TopAppsView
 
    let context: DeviceActivityReport.Context = .totalActivity
 
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration  {
        var apps: [AppReport] = []
     
        for await activityData in data {
            for await segment in activityData.activitySegments {
                for await segmentCategory in segment.categories {
                    for await application in segmentCategory.applications {
                        apps.append(AppReport(
                            appToken: application.application.token!,
                            timeSpent: application.totalActivityDuration)
                        )
                    }
                }
            }
        }
     
        apps.sort(by: { $0.timeSpent < $1.timeSpent })
        apps = Array(apps.prefix(4))
        
        return AppReportConfiguration(appReports: apps)
    }
}
