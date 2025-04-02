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
    
    init() {
        AppShieldSchedulerService.shared.setupDailyUnshield()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(screenTime)
            //ContentView()
        }
    }

}

// Here we can set a way to display splash screen then profile creation or skip straight to ContentView()
struct RootView: View {
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    @State private var isSplashScreenActive:Bool = true
    
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
