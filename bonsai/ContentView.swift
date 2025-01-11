//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//

import SwiftUI

struct ContentView: View {
    //@StateObject var navGuardService = NavGuardService()

    var body: some View {
        //if navGuardService.isLoggedIn {
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
    //    else {
    //            LoginView()
    //                .environmentObject(navGuardService)
    //        }
//  }
}
