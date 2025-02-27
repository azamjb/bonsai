//
//  ElapsedTimePillReport.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-02-02.
//

import DeviceActivity
import SwiftUI

// MARK: - Define Custom Context for Pill Bar Report
extension DeviceActivityReport.Context {
    static let pillBar = Self("pill Bar")
}

// MARK: - Data Model for a Usage Group
struct UsageGroup: Identifiable {
    var id: String { groupName }
    let groupName: String
    let elapsedTime: TimeInterval   // Time spent (in seconds)
    let totalAllowedTime: TimeInterval  // Allowed time (in seconds)
}

// MARK: - Configuration for PillBarView
struct PillBarViewConfiguration {
    let usageGroups: [UsageGroup]
}

// MARK: - A Custom Slider/Pill View
struct TimeLimitSliderView: View {
    let elapsedTime: TimeInterval
    let totalTime: TimeInterval
    
    // Calculate progress as a value between 0.0 and 1.0.
    private var progress: Double {
        totalTime > 0 ? min(1.0, elapsedTime / totalTime) : 0
    }
    
    /// Format seconds as "Hh Mm"
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Display elapsed vs. allowed time.
            Text("\(formatTime(elapsedTime)) / \(formatTime(totalTime))")
                .font(.caption)
                .foregroundColor(.secondary)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background pill (empty state)
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    // Foreground pill (filled portion)
                    Capsule()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 20)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 20)
        }
    }
}

// MARK: - PillBarView
struct PillBarView: View {
    let configuration: PillBarViewConfiguration
    
    var body: some View {
        // Use a vertical stack to list the pill bars.
        VStack(alignment: .leading, spacing: 16) {
            ForEach(configuration.usageGroups) { group in
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.groupName)
                        .font(.headline)
                    TimeLimitSliderView(elapsedTime: group.elapsedTime, totalTime: group.totalAllowedTime)
                }
            }
        }
        .padding()
    }
}

// MARK: - PillBarReport Scene
struct PillBarReport: DeviceActivityReportScene {
    // Use the custom context for the pill bar report.
    let context: DeviceActivityReport.Context = .pillBar
    
    typealias Configuration = PillBarViewConfiguration
    typealias Content = PillBarView
    
    // Aggregate usage data from DeviceActivityResults.
    // In this example, we group usage by category (similar to your pie chart) and assign a fixed allowed time.
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        var usageDict: [String: TimeInterval] = [:]
        
        for await activityData in data {
            for try await segment in activityData.activitySegments {
                for try await category in segment.categories {
                    // Use the localized display name (or "Unknown")
                    let categoryName = category.category.localizedDisplayName ?? "Unknown"
                    usageDict[categoryName, default: 0] += category.totalActivityDuration
                }
            }
        }
        
        // For demonstration, we assign a fixed allowed time for each group.
        let defaultAllowedTime: TimeInterval = 7200  // 2 hours in seconds
        
        // Create usage groups (limit to a maximum of 20 groups).
        let groups: [UsageGroup] = usageDict.map { (key, elapsed) in
            UsageGroup(groupName: key, elapsedTime: elapsed, totalAllowedTime: defaultAllowedTime)
        }
            .sorted { $0.groupName < $1.groupName }
            .prefix(20)
            .map { $0 }
        
        return PillBarViewConfiguration(usageGroups: groups)
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            PillBarView(configuration: configuration)
        }
    }
}
