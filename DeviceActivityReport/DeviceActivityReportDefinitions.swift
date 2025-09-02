//
//  DeviceActivityReportDefinitions.swift
//  bonsai
//
//  Created by Brayden O on 2025-09-01.
//  Copyright © 2025 Bonsai Software Incorporated. All rights reserved.
//

import Foundation
import GRDB
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
