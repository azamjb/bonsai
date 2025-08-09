//
//  ElapsedTimePillReport.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-02-02.
//

import DeviceActivity
import SwiftUI
import ManagedSettings

private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: BONSAI_GROUP_NAME)
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
    
    // Cache these computations
    @State private var boundaryExtended: Bool = false
    @State private var extensionCodeSent: Bool = false
    @State private var boundaryReached: Bool = false
    
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                    
                    if boundaryExtended {
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
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .font(Font.system(size: 10))
                            .bold()
                            .frame(width: geometry.size.width, height: 12, alignment: .center)
                    } else if boundaryReached {
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
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .font(Font.system(size: 10))
                            .bold()
                            .frame(width: geometry.size.width, height: 12, alignment: .center)
                        
                    }
                    else if extensionCodeSent {
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
        .onAppear {
            // Load boundary states once on appear
            updateBoundaryStates()
        }
    }
    
    private func updateBoundaryStates() {
        guard let defaults = sharedDefaults else { return }
        
        if let dailyExtensionsData = defaults.data(forKey: DAILY_BOUNDARY_EXTENSIONS_STRING),
           let dailyExtensionsModels = try? JSONDecoder().decode([DailyBoundaryExtensionsModel].self, from: dailyExtensionsData) {
            boundaryExtended = dailyExtensionsModels.contains(where: {
                areDatesSameDay(date1: $0.extendedDateTimeUtc, date2: Date()) && $0.boundaryId == boundaryId
            })
        }
        
        if let activeCodesData = defaults.data(forKey: SENT_EXTENSION_CODES_STRING),
           let activeCodeModels = try? JSONDecoder().decode([SentExtensionCodeModel].self, from: activeCodesData) {
            extensionCodeSent = activeCodeModels.contains(where: {
                areDatesSameDay(date1: $0.sentDateTimeUtc, date2: Date()) && $0.boundaryId == boundaryId
            })
        }
        
        if let boundariesData = defaults.data(forKey: BOUNDARIES_STRING),
           let boundaries = try? JSONDecoder().decode([Boundary].self, from: boundariesData) {
            boundaryReached = boundaries.first(where: { $0.id == boundaryId })?.isBlocked ?? false
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

// MARK: - Optimized PillBarReport Scene
struct PillBarReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .pillBar
    
    typealias Configuration = PillBarViewConfiguration
    typealias Content = PillBarView
    
    private func getBoundaries() -> [Boundary] {
        guard let defaults = sharedDefaults,
              let encoded = defaults.data(forKey: BOUNDARIES_STRING),
              let boundaries = try? JSONDecoder().decode([Boundary].self, from: encoded) else {
            return []
        }
        return boundaries.filter({ $0.weekdays.contains(Weekday.today) })
    }
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        let boundaries = getBoundaries()
        
        // Early return if no boundaries
        guard !boundaries.isEmpty else {
            return PillBarViewConfiguration(usageGroups: [])
        }
        
        // Create lookup structures for O(1) access
        var boundaryLookup: [UUID: Boundary] = [:]
        var categoryToBoundaries: [ActivityCategoryToken: Set<UUID>] = [:]
        var appToBoundaries: [ApplicationToken: Set<UUID>] = [:]
        var webToBoundaries: [WebDomainToken: Set<UUID>] = [:]
        
        // Build lookup tables
        for boundary in boundaries {
            boundaryLookup[boundary.id] = boundary
            
            for token in boundary.categoryTokens {
                categoryToBoundaries[token, default: []].insert(boundary.id)
            }
            
            for token in boundary.appTokens {
                appToBoundaries[token, default: []].insert(boundary.id)
            }
            
            for token in boundary.webDomainTokens {
                webToBoundaries[token, default: []].insert(boundary.id)
            }
        }
        
        var usageByBoundary: [UUID: TimeInterval] = [:]
        
        for await activityData in data {
            for await segment in activityData.activitySegments {
                for await category in segment.categories {
                    let categoryToken = category.category.token
                    
                    if let boundaryIds = categoryToBoundaries[categoryToken!] {
                        for boundaryId in boundaryIds {
                            usageByBoundary[boundaryId, default: 0] += category.totalActivityDuration
                        }
                    }
                    
                    for await app in category.applications {
                        if let boundaryIds = appToBoundaries[app.application.token!] {
                            for boundaryId in boundaryIds {
                                usageByBoundary[boundaryId, default: 0] += app.totalActivityDuration
                            }
                        }
                    }
                    
                    for await webDomain in category.webDomains {
                        if let boundaryIds = webToBoundaries[webDomain.webDomain.token!] {
                            for boundaryId in boundaryIds {
                                usageByBoundary[boundaryId, default: 0] += webDomain.totalActivityDuration
                            }
                        }
                    }
                }
            }
        }
        
        var usageGroups: [UsageGroup] = []
        for boundary in boundaries {
            let elapsedTime = usageByBoundary[boundary.id] ?? 0
            let totalTime = TimeInterval(boundary.hours * 3600 + boundary.minutes * 60)
            
            usageGroups.append(
                UsageGroup(
                    id: boundary.id,
                    groupName: boundary.givenName,
                    elapsedTime: elapsedTime,
                    totalAllowedTime: totalTime
                )
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
