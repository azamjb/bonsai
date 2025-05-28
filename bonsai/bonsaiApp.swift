//
//  bonsaiApp.swift
//  bonsai
//
//  Created by Azam Jawad on YYYY-MM-DD.
//

import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import ManagedSettings
import ManagedSettingsUI
import BackgroundTasks

@main
struct bonsaiApp: App {
    @StateObject private var screenTime = ScreenTimeService()
    @StateObject private var notificationHandler = NotificationHandler.shared
    @StateObject private var quoteViewModel = QuoteViewModel()
    
    init() {
        NightlySchedulerService.shared.setupDailyUnshield()
        WeeklySchedulerService.shared.setupWeeklySchedule()
        NotificationHandler.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(screenTime)
                    .environmentObject(quoteViewModel)
                    .environmentObject(notificationHandler)
                    .environmentObject(DeviceReportsManager.shared)
                //ContentView()
            }
        }
    }

}

// Here we can set a way to display splash screen then profile creation or skip straight to ContentView()
struct RootView: View {
    @AppStorage("isProfileCreated") public var isProfileCreated = false
    @State private var isSplashScreenActive: Bool = false
    
    var body: some View {
        Group {
            if isSplashScreenActive {
                LandingPageView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                // Switch to main app after 3 seconds
                                isSplashScreenActive = false
                            }
                        }
                    }
            } else {
                if isProfileCreated {
                    ContentView()
                } else {
                    InspireView()
                }
            }
        }
    }
}
