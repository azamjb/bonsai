//
//  deviceactivityreport.swift
//  deviceactivityreport
//
//  Created by Azam Jawad on 2024-11-29.
//

import DeviceActivity
import SwiftUI


@main
struct deviceactivityreport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        
        PieChartReport()
        PillBarReport()
        // Add more reports here...
    }
}
