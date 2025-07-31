//
//  ActivityReportView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-12-30.
//

import SwiftUI
import DeviceActivity
import FamilyControls

enum AnalyticsDisplaysType: Int {
    case daily = 1, weekly = 2, monthly = 3

    var fullName: String {
        switch self {
        case .daily:
            return "DAILY"
        case .weekly:
            return "WEEKLY"
        case .monthly:
            return "MONTHLY"
        }
    }
}

struct ActivityReportView: View {
    @Binding var tabSelection: Int

    let center = AuthorizationCenter.shared

    @AppStorage("hasAccountabilityPartner") var hasAccountabilityPartner: Bool = false
    @EnvironmentObject var reportsManager: DeviceReportsManager
    @StateObject var viewModel: ActivityReportViewModel = ActivityReportViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService
    @State private var isAuthorized = false

    var now = Date()

    private let dayFilter = DeviceActivityFilter(
        segment: .daily(during: Calendar.current.dateInterval(of: .day, for: .now)!),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    private let weekFilter = DeviceActivityFilter(
        segment: .weekly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            end: Date()
        )),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    private let monthFilter = DeviceActivityFilter(
        segment: .weekly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            end: Date()
        )),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    @State private var analyticsRange: AnalyticsDisplaysType = .daily
    
    // Loading states for individual reports
    @State private var isTotalActivityLoaded = false
    @State private var isPillBarLoaded = false
    @State private var isAnalyticsLoaded = false
    
    // Retry tracking
    @State private var totalActivityRetries = 0
    @State private var pillBarRetries = 0
    @State private var analyticsRetries = 0
    @State private var loadingTimers: [String: Timer] = [:]
    
    private let maxRetries = 3
    private let loadingTimeout: TimeInterval = 5.0 // 5 seconds timeout
    
    var body: some View {
        ScrollView {
            VStack {
                // Add refresh button if any reports failed to load
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await forceRefreshReports()
                        }
                    }) {
                        Label("", systemImage: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 20)
                }
                
                // Total Screen Time Section - Always visible
                Group {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("TOTAL")
                                .foregroundColor(.secondary)
                                .font(.system(size: 10))

                            Text("SCREEN TIME")
                                .foregroundColor(.secondary)
                                .font(.system(size: 10))
                        }

                        Spacer()

                        Text(mediumDateFormat(date: Date()))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 11))
                    }
                    .padding(.horizontal, 75)

                    if isAuthorized && isTotalActivityLoaded {
                        DeviceActivityReport(.init(rawValue: "total_activity"), filter: dayFilter)
                            .frame(height: 50)
                            .transition(.opacity)
                    } else {
                        ProgressView()
                            .frame(height: 50)
                    }
                }
                .padding(.top, 10)

                HStack {
                    Image("koibois")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                }
                .padding(.bottom, 25)
                .padding(.top, 25)

                if hasAccountabilityPartner {
                    Group {
                        VStack(alignment: .leading) {
                            Text("BOUNDARIES")
                                .padding(.horizontal, 18)
                                .padding(.bottom, 20)
                                .fontWeight(.bold)
                            
                            if screenTime.getBoundariesFromUserDefaults().isEmpty {
                                Text("No boundaries are active for today.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.bottom, 10)
                                    .padding(.horizontal, 20)
                            }

                            if isAuthorized {
                                ZStack {
                                    if !isPillBarLoaded {
                                        VStack {
                                            ProgressView()
                                            if pillBarRetries > 0 {
                                                Text("Retrying... (\(pillBarRetries)/\(maxRetries))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .frame(height: CGFloat(max(1, screenTime.boundariesSetToday.count)) * 90)
                                    }
                                    
                                    DeviceActivityReport(.init(rawValue: "pill_bar"), filter: dayFilter)
                                        .frame(height: CGFloat(screenTime.boundariesSetToday.count) * 90)
                                        .id("pillBar_\(screenTime.boundariesSetToday.count)_\(pillBarRetries)")
                                        .opacity(isPillBarLoaded ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.3), value: isPillBarLoaded)
                                }
                                .padding(.horizontal, 18)
                            } else {
                                ProgressView()
                                    .frame(height: CGFloat(max(1, screenTime.boundariesSetToday.count)) * 90)
                                    .padding(.horizontal, 18)
                            }

                            Text("BOUNDARY EXTENSIONS")
                                .padding(.horizontal, 18)
                                .padding(.top, 10)
                                .font(.system(size: 10))
                        }

                        dailyBoundaryExtensionsView(models: screenTime.getDailyBoundaryExtensionsModels())
                            .padding(.bottom, 30)
                    }
                }

                VStack(alignment: .leading) {
                    Divider()
                        .frame(height: 1)
                        .background(Color.primary)
                        .padding(.bottom, 20)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("ANALYTICS")
                                .padding(.bottom, 5)

                            Spacer()

                            Menu {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        analyticsRange = .daily
                                    }
                                } label: {
                                    Text("DAILY")
                                        .foregroundStyle(Color.primary)
                                }
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        analyticsRange = .weekly
                                    }
                                } label: {
                                    Text("WEEKLY")
                                        .foregroundStyle(Color.primary)
                                }
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        analyticsRange = .monthly
                                    }
                                } label: {
                                    Text("MONTHLY")
                                        .foregroundStyle(Color.primary)
                                }
                            } label: {
                                Label(analyticsRange.fullName, systemImage: "chevron.down")
                                    .foregroundStyle(Color.primary)
                            }
                        }

                        Text("Top 4 apps and daily usage")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)

                        Text(mediumDateFormat(date: Date.now))
                            .font(.caption)
                            .foregroundStyle(Color.secondary)

                        if isAuthorized {
                            ZStack {
                                if !isAnalyticsLoaded {
                                    ProgressView()
                                        .frame(height: 120)
                                }
                                
                                // Use id modifier to force re-render when range changes
                                Group {
                                    switch analyticsRange {
                                    case .daily:
                                        DeviceActivityReport(.init(rawValue: "top_apps_daily_report"), filter: dayFilter)
                                    case .weekly:
                                        DeviceActivityReport(.init(rawValue: "top_apps_weekly_report"), filter: weekFilter)
                                    case .monthly:
                                        DeviceActivityReport(.init(rawValue: "top_apps_monthly_report"), filter: monthFilter)
                                    }
                                }
                                .frame(height: 120)
                                .id("\(analyticsRange.rawValue)")
                                .opacity(isAnalyticsLoaded ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: isAnalyticsLoaded)
                            }
                        } else {
                            ProgressView()
                                .frame(height: 120)
                        }
                    }
                }
                .padding(.horizontal, 18)

                if hasAccountabilityPartner {
                    Group {
                        Divider()
                            .frame(height: 1)
                            .background(Color.primary)
                            .padding(.bottom, 20)
                            .padding(.top, 10)

                        Text("EXTEND BOUNDARIES")
                            .padding(.bottom, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationStack {
                            BonsaiNavLinkSmall(buttonText: "request boundary extension", destination: BoundaryExtensionRequestView())
                                .padding(.bottom, 30)
                            
                            BonsaiNavLinkSmall(buttonText: "override boundaries", destination: OverrideBoundaryView(screenTime))
                                .padding(.bottom, 40)
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal, 18)
        }
        .onAppear {
            Task {
                do {
                    try await center.requestAuthorization(for: .individual)
                    await MainActor.run {
                        isAuthorized = true
                    }
                } catch {
                    print("Failed to request authorization: \(error)")
                    return
                }
                
                await loadReportsInPriority()
            }
        }
        .onChange(of: analyticsRange) { _, _ in
            // Only reload analytics when range changes
            isAnalyticsLoaded = false
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                await MainActor.run {
                    isAnalyticsLoaded = true
                }
            }
        }
        .onDisappear {
            // Clean up timers when view disappears
            for (_, timer) in loadingTimers {
                timer.invalidate()
            }
            loadingTimers.removeAll()
        }
    }
    
    // MARK: - Prioritized Loading
    private func loadReportsInPriority() async {
        startLoadingTimer(for: "totalActivity")
        
        await MainActor.run {
            isTotalActivityLoaded = true
        }
        cancelLoadingTimer(for: "totalActivity")
        
        try? await Task.sleep(nanoseconds: 70_000_000)
        
        if hasAccountabilityPartner {
            startLoadingTimer(for: "pillBar")
            await MainActor.run {
                isPillBarLoaded = true
            }
            cancelLoadingTimer(for: "pillBar")
            try? await Task.sleep(nanoseconds: 70_000_000) 
        }
        
        startLoadingTimer(for: "analytics")
        await MainActor.run {
            isAnalyticsLoaded = true
        }
        cancelLoadingTimer(for: "analytics")
    }
    
    // MARK: - Retry Logic
    private func startLoadingTimer(for report: String) {
        let timer = Timer.scheduledTimer(withTimeInterval: loadingTimeout, repeats: false) { _ in
            Task {
                await handleLoadingTimeout(for: report)
            }
        }
        loadingTimers[report] = timer
    }
    
    private func cancelLoadingTimer(for report: String) {
        loadingTimers[report]?.invalidate()
        loadingTimers[report] = nil
    }
    
    private func handleLoadingTimeout(for report: String) async {
        await MainActor.run {
            switch report {
            case "totalActivity":
                if !isTotalActivityLoaded && totalActivityRetries < maxRetries {
                    totalActivityRetries += 1
                    print("Total Activity Report failed to load, retry \(totalActivityRetries)/\(maxRetries)")
                    retryLoadingReport(report)
                }
            case "pillBar":
                if !isPillBarLoaded && pillBarRetries < maxRetries {
                    pillBarRetries += 1
                    print("Pill Bar Report failed to load, retry \(pillBarRetries)/\(maxRetries)")
                    retryLoadingReport(report)
                }
            case "analytics":
                if !isAnalyticsLoaded && analyticsRetries < maxRetries {
                    analyticsRetries += 1
                    print("Analytics Report failed to load, retry \(analyticsRetries)/\(maxRetries)")
                    retryLoadingReport(report)
                }
            default:
                break
            }
        }
    }
    
    private func retryLoadingReport(_ report: String) {
        Task {
            await MainActor.run {
                switch report {
                case "totalActivity":
                    isTotalActivityLoaded = false
                case "pillBar":
                    isPillBarLoaded = false
                case "analytics":
                    isAnalyticsLoaded = false
                default:
                    break
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            startLoadingTimer(for: report)
            await MainActor.run {
                switch report {
                case "totalActivity":
                    isTotalActivityLoaded = true
                case "pillBar":
                    isPillBarLoaded = true
                case "analytics":
                    isAnalyticsLoaded = true
                default:
                    break
                }
            }
            cancelLoadingTimer(for: report)
        }
    }
    
    // MARK: - Force Refresh
    private func forceRefreshReports() async {
        await MainActor.run {
            isTotalActivityLoaded = false
            isPillBarLoaded = false
            isAnalyticsLoaded = false
            totalActivityRetries = 0
            pillBarRetries = 0
            analyticsRetries = 0
        }
        
        for (_, timer) in loadingTimers {
            timer.invalidate()
        }
        loadingTimers.removeAll()
        
        await loadReportsInPriority()
    }
   
    private func dailyBoundaryExtensionsView(models: [DailyBoundaryExtensionsModel]) -> some View {
        HStack(spacing: 1) {
            extensionCountView(color: "0x1E2368", day: "MON", count: getAmountOfExtensionsForWeekday(weekday: .monday, models: models))
            extensionCountView(color: "0x454380", day: "TUE", count: getAmountOfExtensionsForWeekday(weekday: .tuesday, models: models))
            extensionCountView(color: "0x7D4077", day: "WED", count: getAmountOfExtensionsForWeekday(weekday: .wednesday, models: models))
            extensionCountView(color: "0x9D3B6A", day: "THU", count: getAmountOfExtensionsForWeekday(weekday: .thursday, models: models))
            extensionCountView(color: "0xDB6552", day: "FRI", count: getAmountOfExtensionsForWeekday(weekday: .friday, models: models))
            extensionCountView(color: "0xE56829", day: "SAT", count: getAmountOfExtensionsForWeekday(weekday: .saturday, models: models))
            extensionCountView(color: "0xC95102", day: "SUN", count: getAmountOfExtensionsForWeekday(weekday: .sunday, models: models))
        }
    }
    
    private func getAmountOfExtensionsForWeekday(weekday: Weekday, models: [DailyBoundaryExtensionsModel]) -> Int {
        let models = models.filter({ areDatesSameDay(date1: $0.extendedDateTimeUtc, date2: (getDateInWeekStartingFromThisMonday(weekday: weekday) ?? Date.distantFuture)) })
        return models.count
    }

    private func extensionCountView(color: String, day: String, count: Int) -> some View {
        ZStack {
            Rectangle()
                .frame(width: 45, height: 60)
                .foregroundColor(Color(hex: color))
                .cornerRadius(10)

            VStack {
                Text(String(count))
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text(day)
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    ActivityReportView(tabSelection: .constant(0))
        .environmentObject(ScreenTimeService())
}
