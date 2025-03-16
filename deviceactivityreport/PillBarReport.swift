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
            
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background pill (empty state)
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)

                    // Foreground gradient (full width)
                    LinearGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(hex: "0x121961"), location: 0.0),
                            Gradient.Stop(color: Color(hex: "0x534E88"), location: 0.25),
                            Gradient.Stop(color: Color(hex: "0x97366B"), location: 0.5),
                            Gradient.Stop(color: Color(hex: "0xF87946"), location: 0.75),
                            Gradient.Stop(color: Color(hex: "0xC95001"), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width, height: 10) // ✅ Progress width now controls fill area
                    .mask( // ✅ Only reveal the filled portion
                                    HStack {
                                        Rectangle()
                                            .frame(width: geometry.size.width * CGFloat(progress), height: 10)
                                        Spacer() // Ensures gradient starts from the left
                                    }
                                )
                    .clipShape(Capsule()) // ✅ Keeps rounded edges when clipped
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
    
    /// Format seconds as "Hh Mm"
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
     
    
    var body: some View {
        // Use a vertical stack to list the pill bars.
        VStack(alignment: .leading, spacing: 16) {
            ForEach(configuration.usageGroups) { group in
                
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        
                        Text("LABEL")
                            .font(.system(size: 10))
                        
                        Spacer()
                        
                        Text("DAILY LIMIT")
                            .font(.system(size: 10))
                        
                    }
                    
                    HStack {
                        
                        Text(group.groupName)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(formatTime(group.elapsedTime)) / \(formatTime(group.totalAllowedTime))")
                            .font(.system(size: 15))
                            .foregroundColor(.black)

                        
                    }
                    
                        
                                        
                    TimeLimitSliderView(elapsedTime: group.elapsedTime, totalTime: group.totalAllowedTime)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame( height: 500)
        .padding()
    }
}


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
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
