//
//  PieChartReport.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-29.
//

import DeviceActivity
import SwiftUI
import Charts

// MARK: - Define Custom Contexts
extension DeviceActivityReport.Context {
    static let pieChart = Self("pie_chart")
}

// MARK: - Configuration for PieChartView
struct PieChartViewConfiguration {
    let totalUsageByCategory: [String: TimeInterval]
}

// MARK: - PieChartView
struct PieChartView: View {
    let configuration: PieChartViewConfiguration

    var body: some View {
        VStack {
            
            Chart {
                ForEach(configuration.totalUsageByCategory.keys.sorted(), id: \.self) { category in
                    let duration = configuration.totalUsageByCategory[category] ?? 0
                    SectorMark(
                        angle: .value("Duration", duration),
                        innerRadius: .ratio(0.5),
                        outerRadius: .ratio(1.0)
                    )
                    .foregroundStyle(by: .value("Category", category))
                    
                }
            }
            .chartLegend(.visible)
            .frame(height: 300)
            .padding(.top,10)

        }
        .padding()
    }

    private func formatTotalDuration() -> String {
        let totalDuration = configuration.totalUsageByCategory.values.reduce(0, +)
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - PieChartReport
struct PieChartReport: DeviceActivityReportScene {
    // Define the context for the scene
    let context: DeviceActivityReport.Context = .pieChart

    // Associated types
    typealias Configuration = PieChartViewConfiguration
    typealias Content = PieChartView

    // Generate the configuration based on activity data
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        var totalUsageByCategory: [String: TimeInterval] = [:]

        for await activityData in data {
            for try await segment in activityData.activitySegments {
                // Access categories directly from the segment
                for try await category in segment.categories {
                    // Get the localized name of the category
                    let categoryName = category.category.localizedDisplayName ?? "Unknown"
                    // Sum up the total activity duration
                    totalUsageByCategory[categoryName, default: 0] += category.totalActivityDuration
                }
            }
        }

        // Return the configuration for the pie chart
        return PieChartViewConfiguration(totalUsageByCategory: totalUsageByCategory)
    }

    // Closure that builds the content view
    var content: (Configuration) -> Content {
        return { configuration in
            PieChartView(configuration: configuration)
        }
    }
}
