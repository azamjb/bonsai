//
//  ElapsedTimePillReport.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-02-02.
//

import DeviceActivity
import SwiftUI
import ManagedSettings

private let appGroupID = "group.com.bonsai"

private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: appGroupID)
}

// MARK: - Define Custom Context for Pill Bar Report
extension DeviceActivityReport.Context {
    static let pillBar = Self("pill_bar")
}

// MARK: - Data Model for a Usage Group
struct UsageGroup: Identifiable {
    var id: UUID
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
    let boundaryId: UUID
    
    // Calculate progress as a value between 0.0 and 1.0.
    private var progress: Double {
        totalTime > 0 ? min(1.0, elapsedTime / totalTime) : 0.0
    }
    
    /// Format seconds as "Hh Mm"
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func hasBoundaryBeenExtendedToday(id: UUID) -> Bool {
        if let dailyExtensionsData = sharedDefaults!.data(forKey: DAILY_BOUNDARY_EXTENSIONS_STRING) {
            do {
                let dailyExtensionsModels = try JSONDecoder().decode([DailyBoundaryExtensionsModel].self, from: dailyExtensionsData)
                return dailyExtensionsModels.contains(where: { areDatesSameDay(date1: $0.extendedDateTimeUtc, date2: Date()) && $0.boundaryId == id })
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    private func hasExtensionCodeBeenSentForBoundary(id: UUID) -> Bool {
        if let activeCodesData = sharedDefaults!.data(forKey: SENT_EXTENSION_CODES_STRING) {
            do {
                let activeCodeModels = try JSONDecoder().decode([SentExtensionCodeModel].self, from: activeCodesData)
                return activeCodeModels.contains(where: { areDatesSameDay(date1: $0.sentDateTimeUtc, date2: Date()) && $0.boundaryId == id })
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    private func hasBoundaryBeenReached(id: UUID) -> Bool {
        if let boundariesData = sharedDefaults!.data(forKey: BOUNDARIES_STRING) {
            do {
                let boundaries = try JSONDecoder().decode([Boundary].self, from: boundariesData)
                let boundary = boundaries.first(where: { $0.id == id })
                
                return boundary?.isBlocked ?? false
            } catch {
                return false
            }
        } else {
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                    
                    if hasBoundaryBeenExtendedToday(id: boundaryId) {
                        ZStack(alignment: .leading) {
                            LinearGradient(
                                gradient: Gradient(stops: [Gradient.Stop(color: Color.primary, location: 0.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geometry.size.width, height: 12)
                        }
                        .clipShape(
                            Capsule()
                                .path(in: CGRect(x: 0, y: 0, width: geometry.size.width, height: 12))
                        )
                        
                        Text("BOUNDARY EXTENDED +")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 10))
                            .bold()
                            .frame(width: geometry.size.width, height: 12, alignment: .center)
                    } else if hasBoundaryBeenReached(id: boundaryId) {
                        ZStack(alignment: .leading) {
                            LinearGradient(
                                gradient: Gradient(stops: [Gradient.Stop(color: Color.primary, location: 0.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geometry.size.width, height: 12)
                        }
                        .clipShape(
                            Capsule()
                                .path(in: CGRect(x: 0, y: 0, width: geometry.size.width, height: 12))
                        )
                        
                        Text("BOUNDARY REACHED")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 10))
                            .bold()
                            .frame(width: geometry.size.width, height: 12, alignment: .center)
                        
                    }
                    else if hasExtensionCodeBeenSentForBoundary(id: boundaryId) {
                        ZStack(alignment: .leading) {
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
                            .frame(width: geometry.size.width, height: 12)
                        }
                        .clipShape(
                            Capsule()
                                .path(in: CGRect(x: 0, y: 0, width: geometry.size.width * CGFloat(progress), height: 12))
                        )
                        .animation(.easeInOut, value: progress)
                        
                        Text("EXTENSION CODE SENT")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 10))
                            .bold()
                            .frame(width: geometry.size.width, height: 12, alignment: .center)
                        
                    }
                    else {
                        ZStack(alignment: .leading) {
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
                            .frame(width: geometry.size.width, height: 12)
                        }
                        .clipShape(
                            Capsule()
                                .path(in: CGRect(x: 0, y: 0, width: geometry.size.width * CGFloat(progress), height: 12))
                        )
                        .animation(.easeInOut, value: progress)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - PillBarView
struct PillBarView: View {
    let configuration: PillBarViewConfiguration
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
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
                        
                        Text("\(formatTime(min(group.elapsedTime, group.totalAllowedTime))) / \(formatTime(group.totalAllowedTime))")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                    }
                    
                    TimeLimitSliderView(elapsedTime: group.elapsedTime, totalTime: group.totalAllowedTime, boundaryId: group.id)
                }
            }
        }
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
    
    private func getBoundaries() -> [Boundary] {
        let encoded = sharedDefaults!.data(forKey: BOUNDARIES_STRING)
        
        if encoded != nil {
            return try! JSONDecoder().decode([Boundary].self, from: encoded!)
        } else {
            return []
        }
    }
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        var usageGroups: [UsageGroup] = []
        let boundaries = getBoundaries()

        for boundary in boundaries {
            var elapsedTime = TimeInterval(0)
            
            for await activityData in data {
                for try await segment in activityData.activitySegments {
                    for try await segmentCategory in segment.categories {
                        if boundary.categoryTokens.contains(where: { $0 == segmentCategory.category.token }) {
                            elapsedTime += segmentCategory.totalActivityDuration
                            
                            // If the whole category exists in the limit, skip to the next iteration since we use the category to check its containing apps.
                            continue
                        }
                        
                        // Go through each app where the app exists in the User's limits
                        for try await application in segmentCategory.applications {
                            if boundary.appTokens.contains(where: { $0 == application.application.token }) {
                                elapsedTime += application.totalActivityDuration
                            }
                        }
                        
                        // Go through each web domain where the app exists in the User's limits
                        for try await webDomain in segmentCategory.webDomains {
                            if boundary.webDomainTokens.contains(where: { $0 == webDomain.webDomain.token }) {
                                elapsedTime += webDomain.totalActivityDuration
                            }
                        }
                    }
                }
            }
            
            usageGroups.insert(
                UsageGroup(
                    id: boundary.id,
                    groupName: boundary.givenName,
                    elapsedTime: elapsedTime,
                    totalAllowedTime: TimeInterval(boundary.hours * 3600 + boundary.minutes * 60)
                ),
                at: 0
            )
        }
        
        return PillBarViewConfiguration(usageGroups: usageGroups)
    }
    
    
    var content: (Configuration) -> Content {
        return { configuration in
            PillBarView(configuration: configuration)
        }
    }
}
