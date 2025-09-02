//
//  deviceactivityreport.swift
//  deviceactivityreport
//
//  Created by Azam Jawad on 2024-11-29.
//

import Foundation
import DeviceActivity
import SwiftUI

@main
struct DeviceActivityReportScenes: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport()
        PieChartReport()
        PillBarReport()
        TopAppsDailyReport()
        TopAppsWeeklyReport()
        TopAppsMonthlyReport()
    }
}
