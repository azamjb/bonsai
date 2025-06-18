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

    @State private var dayFilter = DeviceActivityFilter(
        segment: .daily(during: Calendar.current.dateInterval(of: .day, for: .now)!),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    @State private var weekFilter = DeviceActivityFilter(
        segment: .weekly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            end: Date()
        )),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    @State private var monthFilter = DeviceActivityFilter(
        segment: .weekly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            end: Date()
        )),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    @State private var analyticsRange: AnalyticsDisplaysType = .daily
    @State private var refreshID = UUID()

    var body: some View {

            ScrollView {
                VStack {
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

                        DeviceActivityReport(.init(rawValue: "total_activity"), filter: dayFilter)
                            .frame(height: 50)
                    }
                    .padding(.top, 30)

                    HStack {
                        Image("koibois")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350)
                    }
                    .padding(.bottom, 25)
                    .padding(.top, 25)


                    if (hasAccountabilityPartner) {

                        Group {

                            VStack(alignment: .leading) {
                                Text("BOUNDARIES")
                                    .padding(.horizontal, 18)
                                    .padding(.bottom, 20)

                                DeviceActivityReport(.init(rawValue: "pill_bar"), filter: dayFilter)
                                    .frame(height: CGFloat(screenTime.boundariesSet.count) * 90)
                                    .padding(.horizontal, 18)


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
                                        analyticsRange = .daily
                                    } label: {
                                        Text("DAILY")
                                            .foregroundStyle(Color.primary)
                                    }
                                    Button {
                                        analyticsRange = .weekly
                                    } label: {
                                        Text("WEEKLY")
                                            .foregroundStyle(Color.primary)
                                    }
                                    // TODO - Fix monthly

                                    Button {
                                        analyticsRange = .monthly
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

                            ZStack {
                                // The reason im showing/hiding with conditional opactity is cuz the conditional would make it need to reaggregate the data, which sometimes left the area blank for some time (it's async)
                                if isAuthorized {
                                    DeviceActivityReport(.init(rawValue: "top_apps_daily_report"), filter: dayFilter)
                                        .opacity(analyticsRange == .daily ? 1 : 0)
                                }

                                if isAuthorized {
                                    DeviceActivityReport(.init(rawValue: "top_apps_weekly_report"), filter: weekFilter)
                                            .opacity(analyticsRange == .weekly ? 1 : 0)
                                }

                                if isAuthorized {
                                    DeviceActivityReport(.init(rawValue: "top_apps_monthly_report"), filter: monthFilter)
                                            .opacity(analyticsRange == .monthly ? 1 : 0)
                                }


                            }
                            .frame(height: 120)
                        }

                    }
                    .padding(.horizontal, 18)

                    if (hasAccountabilityPartner) {

                        Group {
                            Divider()
                                .frame(height: 1)
                                .background(Color.primary)
                                .padding(.bottom, 20)

                            Text("EXTEND BOUNDARIES")
                                .padding(.bottom, 30)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            NavigationStack{
                                BonsaiNavLinkSmall(buttonText: "request boundary extension", destination: BoundaryExtensionRequestView())
                                    .padding(.bottom, 30)
                                
                                BonsaiNavLinkSmall(buttonText: "override boundaries", destination: OverrideBoundaryView(screenTime))
                                    .padding(.bottom, 30)
                            }
                            

//                            BonsaiButtonSmall(buttonText: "override all boundaries (testing only)") {
//                                screenTime.clearShieldedApps()
//                            }
//                            .padding(.bottom, 50)
                        }
                        .padding(.horizontal, 18)
                    }


                }
                .id(refreshID)
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
                    }
                }
                
                refreshID = UUID()
            }

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
                .foregroundColor(Color(hex: color)) // Change color
                .cornerRadius(10) // Optional rounded corners

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
