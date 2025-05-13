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
    @EnvironmentObject var notificationHandler: NotificationHandler
    
    var body: some View {
        TabView(selection: $tabSelection) {
            
            NavigationStack {
                ActivityReportView(tabSelection: $tabSelection)
            }
            .tabItem {
                Label("Activity", systemImage: "chart.pie")
            }
            .tag(1)
            
            NavigationStack {
                BoundaryViewerView(tabSelection: $tabSelection)
            }
            .tabItem {
                Label("Boundaries", systemImage: "shield.lefthalf.filled")
            }
            .tag(2)
            
            
            NavigationStack {
                ProfileView(viewModel: viewModel)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        .sheet(isPresented: $notificationHandler.showExtensionRequest) {
            BoundaryExtensionRequestView()
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
