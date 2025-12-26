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

    // iOS 17+: tap selection for pie charts
    @State private var selectedAngle: Double? = nil
    @State private var selectedCategory: String? = nil

    private var items: [(category: String, duration: TimeInterval)] {
        configuration.totalUsageByCategory
            .map { ($0.key, $0.value) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var total: TimeInterval {
        items.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        ZStack {
            // PIE
            Chart(items, id: \.category) { item in
                SectorMark(
                    angle: .value("Duration", item.duration),
                    innerRadius: .ratio(0.58),
                    outerRadius: .ratio(1.0)
                )
                .foregroundStyle(by: .value("Category", item.category))
                .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.35)
            }
            .chartLegend(.hidden)
            .frame(width: 170, height: 170)
            .chartAngleSelection(value: $selectedAngle)
            .onChange(of: selectedAngle) { _, newValue in
                guard let newValue else {
                    selectedCategory = nil
                    return
                }
                selectedCategory = categoryForAngle(newValue)
            }

            // TOOLTIP
            if let selectedCategory,
               let selected = items.first(where: { $0.category == selectedCategory }) {

                let pct = total > 0 ? selected.duration / total : 0

                VStack(spacing: 4) {
                    Text(selected.category)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)

                    Text("\(formatDuration(selected.duration)) • \(Int((pct * 100).rounded()))%")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: selectedCategory)
            }
        }
        // Tap outside to clear
        .contentShape(Rectangle())
        .onTapGesture {
            // If the user taps the empty area around the chart/tooltip, clear selection
            // (Tapping a slice will set selectedAngle via chartAngleSelection)
            selectedAngle = nil
            selectedCategory = nil
        }
        .padding()
    }

    // MARK: - Map selected angle -> which slice
    private func categoryForAngle(_ angle: Double) -> String? {
        // Charts gives angle in degrees (0...360). We map it to cumulative slice sizes.
        guard total > 0 else { return nil }

        let normalized = angle.truncatingRemainder(dividingBy: 360)
        var running: Double = 0

        for item in items {
            let slice = (item.duration / total) * 360.0
            running += slice
            if normalized <= running {
                return item.category
            }
        }
        return items.last?.category
    }

    private func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let rem = minutes % 60
        return rem == 0 ? "\(hours)h" : "\(hours)h \(rem)m"
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
