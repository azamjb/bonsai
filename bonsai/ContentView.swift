//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                ActivityReportView()
                    .tabItem {
                        Label("Activity", systemImage: "chart.pie")
                    }

                MonitorView()
                    .tabItem {
                        Label("Monitoring", systemImage: "gearshape")
                    }
                
                AccountabilityPartnerView()
                    .tabItem {
                        Label("Accountability", systemImage: "person.fill")
                    }
            }
        }
}

#Preview {
    ContentView()
}
