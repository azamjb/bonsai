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
    @Binding var tabSelection: Int

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
            ScrollView {
                VStack {
                    Group {
                        DeviceActivityReport(.init(rawValue: "Total Activity"), filter: filter)
                            .frame(height: 300)
                    }
                    Group {
                        DeviceActivityReport(.init(rawValue: "pie Chart"), filter: filter)
                            .frame(height: 400)
                    }
                    Group {
                        DeviceActivityReport(.init(rawValue: "pill Bar"), filter: filter)
                            .frame(height: 1536)
                    }
                }
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
