//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//

import SwiftUI
import ManagedSettings

struct ContentView: View {
    
    @State private var tabSelection = 1
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        TabView(selection: $tabSelection) {
            ActivityReportView(tabSelection: $tabSelection)
                .tabItem {
                    Label("Activity", systemImage: "chart.pie")
                }
                .tag(1)
            
            MonitorView(tabSelection: $tabSelection)
                .tabItem {
                    Label("Monitoring", systemImage: "gearshape")
                }
                .tag(2)

            AccountabilityPartnerView(tabSelection: $tabSelection)
                .tabItem {
                    Label("Accountability", systemImage: "person.fill")
                }
                .tag(3)
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

// A SwiftUI preview.
#Preview {
    ContentView()
}

// A SwiftUI preview.
#Preview {
    ContentView()
}
