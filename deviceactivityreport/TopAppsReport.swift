//
//  AppReport.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-26.
//

import ManagedSettings
import Foundation
import SwiftUICore
import SwiftUI
import FamilyControls
import _DeviceActivity_SwiftUI

extension DeviceActivityReport.Context {
    static let dailyAppReport = Self("top_apps_daily_report")
    static let weeklyAppReport = Self("top_apps_weekly_report")
    static let monthlyAppReport = Self("top_apps_monthly_report")
}

struct TopAppReport: Identifiable, Hashable {
    var id: UUID = UUID()
    var appToken: ApplicationToken
    var timeSpent: TimeInterval
}

struct TopAppsReportConfiguration {
    let topAppReports: [TopAppReport]
}

struct TopAppsView: View {
    let configuration: TopAppsReportConfiguration
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h, \(minutes)m"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if configuration.topAppReports.isEmpty {
                Text("No app usage data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(0..<min(4, configuration.topAppReports.count), id: \.self) { index in
                        AppReportDisplay(
                            appToken: configuration.topAppReports[index].appToken,
                            displayTime: formatTime(configuration.topAppReports[index].timeSpent)
                        )
                    }
                }
            }
        }
    }
}

struct AppTokenIconStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .scaleEffect(1.5)
            .foregroundColor(.blue)
    }
}

struct AppTokenTitleStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .font(.system(size: 11))
            .foregroundColor(.primary)
            .lineLimit(1)
    }
}

struct AppReportDisplay: View {
    let appToken: ApplicationToken
    let displayTime: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 140, height: 40)
                
                HStack(alignment: .center, spacing: 8) {
                    Label(appToken)
                        .labelStyle(AppTokenIconStyle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label(appToken)
                            .labelStyle(AppTokenTitleStyle())
                        
                        Text(displayTime)
                            .font(.system(size: 11))
                            .foregroundColor(.primary)
                            .frame(height: 14, alignment: .leading)
                    }
                    .frame(maxWidth: 100, alignment: .leading)
                }
            }
        }
    }
}

struct TopAppsDailyReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .dailyAppReport
    typealias Configuration = TopAppsReportConfiguration
    typealias Content = TopAppsView
 
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration  {
        return await makeConfigurationForPeriod(representing: data, averageByDays: nil)
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            TopAppsView(configuration: configuration)
        }
    }
}

struct TopAppsWeeklyReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .weeklyAppReport
    
    typealias Configuration = TopAppsReportConfiguration
    typealias Content = TopAppsView
 
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration  {
        return await makeConfigurationForPeriod(representing: data, averageByDays: 7)
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            TopAppsView(configuration: configuration)
        }
    }
}

struct TopAppsMonthlyReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .monthlyAppReport
    
    typealias Configuration = TopAppsReportConfiguration
    typealias Content = TopAppsView
 
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration  {
        return await makeConfigurationForPeriod(representing: data, averageByDays: 30)
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            TopAppsView(configuration: configuration)
        }
    }
}

func makeConfigurationForPeriod(representing data: DeviceActivityResults<DeviceActivityData>, averageByDays: Double?) async -> TopAppsReportConfiguration {
    var apps: [TopAppReport] = []
 
    for await activityData in data {
        for await segment in activityData.activitySegments {
            for await segmentCategory in segment.categories {
                for await application in segmentCategory.applications {
                    if let reportIndex = apps.firstIndex(where: { app in app.appToken == application.application.token }) {
                        apps[reportIndex].timeSpent += application.totalActivityDuration
                    } else {
                        apps.append(TopAppReport(
                            appToken: application.application.token!,
                            timeSpent: application.totalActivityDuration)
                        )
                    }
                }
            }
        }
    }
    
    if averageByDays != nil {
        for i in 0..<apps.count {
            apps[i].timeSpent /= averageByDays!
        }
    }
    
    // take top 4 most used apps
    apps.sort(by: { $0.timeSpent > $1.timeSpent })
    apps = Array(apps.prefix(4))
    
    return TopAppsReportConfiguration(topAppReports: apps)
}
