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

                SecondPageView()
                    .tabItem {
                        Label("Monitoring", systemImage: "gearshape")
                    }
            }
        }
}

#Preview {
    ContentView()
}
