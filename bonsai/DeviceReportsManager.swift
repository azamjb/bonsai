//
//  DeviceReportsManager.swift
//  bonsai
//
//  Created by Brayden O on 2025-05-24.
//

import Foundation
import _DeviceActivity_SwiftUI

class DeviceReportsManager: ObservableObject {
    static let shared = DeviceReportsManager()
    
    let totalActivityReport: DeviceActivityReport
    let pillBarReport: DeviceActivityReport
    let dailyTopAppsReport: DeviceActivityReport
    let weeklyTopAppsReport: DeviceActivityReport
    let monthlyTopAppsReport: DeviceActivityReport
    
    private init() {
        let dayFilter = DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(of: .day, for: .now)!),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
        
        let weekFilter = DeviceActivityFilter(
            segment: .weekly(during: DateInterval(
                start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                end: Date()
            )),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
        
        let monthFilter = DeviceActivityFilter(
            segment: .weekly(during: DateInterval(
                start: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
                end: Date()
            )),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
        
        self.totalActivityReport = DeviceActivityReport(.init(rawValue: "total_activity"), filter: dayFilter)
        self.pillBarReport = DeviceActivityReport(.init(rawValue: "pill_bar"), filter: dayFilter)
        self.dailyTopAppsReport = DeviceActivityReport(.init(rawValue: "top_apps_daily_report"), filter: dayFilter)
        self.weeklyTopAppsReport = DeviceActivityReport(.init(rawValue: "top_apps_weekly_report"), filter: weekFilter)
        self.monthlyTopAppsReport = DeviceActivityReport(.init(rawValue: "top_apps_monthly_report"), filter: monthFilter)
    }
}
