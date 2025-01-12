//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//

import SwiftUI
import ManagedSettings

class SharedAppData: ObservableObject {
    @Published var selectedAppToken: ApplicationToken?
    @Published var selectedCategoryToken: ActivityCategoryToken?
    @Published var webDomainToken: WebDomainToken?
}

struct ContentView: View {
    @StateObject private var sharedAppData = SharedAppData()
    @State private var tabSelection = 1
    
    var body: some View {
        TabView(selection: $tabSelection) {
            ActivityReportView(tabSelection: $tabSelection)
                .tabItem {
                    Label("Activity", systemImage: "chart.pie")
                }
                .tag(1)
            
            MonitorView(tabSelection: $tabSelection, sharedAppData: sharedAppData)
                .tabItem {
                    Label("Monitoring", systemImage: "gearshape")
                }
                .tag(2)

            AccountabilityPartnerView(tabSelection: $tabSelection, sharedAppData: sharedAppData)
                .tabItem {
                    Label("Accountability", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// A SwiftUI preview.
#Preview {
    ContentView()
}
