//
//  ElapsedTimePillReport.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-02-02.
//

import DeviceActivity
import SwiftUI

// MARK: - Define Custom Contexts
extension DeviceActivityReport.Context {
    static let analytics = Self("screenTimeAnalytics")
}

// MARK: - Usage Progress Bar View
struct CategoryProgressView: View {
    let usageTime: TimeInterval
    let limitTime: TimeInterval
    
    private var progress: Double {
        limitTime > 0 ? min(1.0, usageTime / limitTime) : 0
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.0..<0.5: return .green
        case 0.5..<0.8: return .yellow
        default: return .red
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formatTime(usageTime))
                    .foregroundColor(.primary)
                Text("of")
                    .foregroundColor(.secondary)
                Text(formatTime(limitTime))
                    .foregroundColor(.primary)
            }
            .font(.caption)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    Capsule()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 20)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 20)
        }
    }
}

// MARK: - Category Usage Data Model
struct CategoryUsageData {
    let name: String
    let usageTime: TimeInterval
    let limitTime: TimeInterval
}

// MARK: - Analytics Dashboard View
struct ScreenTimeAnalyticsView: View {
    let categoryData: [CategoryUsageData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Screen Time Analytics")
                .font(.title)
                .padding(.bottom, 8)
            
            ForEach(categoryData, id: \.name) { data in
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.name)
                        .font(.headline)
                    CategoryProgressView(
                        usageTime: data.usageTime,
                        limitTime: data.limitTime
                    )
                }
            }
        }
        .padding()
    }
}

// MARK: - Device Activity Report Scene
struct ScreenTimeAnalyticsReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .analytics
    
    typealias Configuration = [CategoryUsageData]
    typealias Content = ScreenTimeAnalyticsView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        let timeExtensionService = TimeExtensionService()
        let limitEvents = timeExtensionService.getGroupDisplay(displayType: .limit)
        
        // Create a dictionary to store category limits
        var categoryLimits: [String: TimeInterval] = [:]
        
        // Process limit events to get time limits for each category
        for event in limitEvents {
            let totalSeconds = TimeInterval(event.hours * 3600 + event.minutes * 60)
            
            if let categoryTokens = event.categoryTokens {
                for token in categoryTokens {
                    let categoryName = token.localizedDisplayName ?? "Unknown"
                    // Store the minimum limit if multiple limits exist
                    if let existingLimit = categoryLimits[categoryName] {
                        categoryLimits[categoryName] = min(existingLimit, totalSeconds)
                    } else {
                        categoryLimits[categoryName] = totalSeconds
                    }
                }
            }
        }
        
        // Process usage data
        var usageDict: [String: TimeInterval] = [:]
        
        for await activityData in data {
            for try await segment in activityData.activitySegments {
                for try await category in segment.categories {
                    let categoryName = category.category.localizedDisplayName ?? "Unknown"
                    usageDict[categoryName, default: 0] += category.totalActivityDuration
                }
            }
        }
        
        // Create usage data array
        let categoryUsage = usageDict.map { (categoryName, usageTime) in
            CategoryUsageData(
                name: categoryName,
                usageTime: usageTime,
                limitTime: categoryLimits[categoryName] ?? 7200 // Default to 2 hours if no limit set
            )
        }
            .sorted { $0.usageTime > $1.usageTime } // Sort by most used first
            .prefix(20) // Limit to top 20 categories
        
        return Array(categoryUsage)
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            ScreenTimeAnalyticsView(categoryData: configuration)
        }
    }
}
