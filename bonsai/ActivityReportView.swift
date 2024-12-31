//
//  ActivityReportView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-12-30.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct ActivityReportView: View {
    let center = AuthorizationCenter.shared

    @State private var context: DeviceActivityReport.Context = .init(rawValue: "pie Chart")
    @State private var context2: DeviceActivityReport.Context = .init(rawValue: "Total Activity")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Text("My Activity")
                    .font(.largeTitle)
                    .padding(.top, 50)

                DeviceActivityReport(context2, filter: filter)
                    .padding(.bottom, 0)
                    .offset(y: -100)

                DeviceActivityReport(context, filter: filter)
                    .padding(.horizontal, 16)
                    .offset(y: -150)
            }
            .onAppear {
                Task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to request authorization: \(error)")
                    }
                }
            }
        }
    }
}
