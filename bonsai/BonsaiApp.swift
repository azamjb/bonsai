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
struct BonsaiApp: App {
    @StateObject private var screenTime = ScreenTimeService()
    @StateObject private var notificationHandler = NotificationHandler.shared
    @StateObject private var quoteViewModel = QuoteViewModel()
    
    @Environment(\.scenePhase) private var scenePhase

    init() {
        NotificationHandler.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(screenTime)
                    .environmentObject(quoteViewModel)
                    .environmentObject(notificationHandler)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                screenTime.setGroupDisplays()
                notificationHandler.scheduleDailySummaryNotification()
            }
        }
    }
}

// Here we can set a way to display splash screen then profile creation or skip straight to ContentView()
struct RootView: View {
    @AppStorage(LAST_LAUNCH_DATE_STRING) private var lastLaunchDateSeconds: Double = 0
    @AppStorage("isProfileCreated") public var isProfileCreated = false
    @State private var isSplashScreenActive: Bool = false
    
    var body: some View {
        Group {
            if isSplashScreenActive {
                LandingPageView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isSplashScreenActive = false
                            }
                        }
                    }
            } else {
                if isProfileCreated {
                    ContentView()
                } else {
                    EducateView()
                }
            }
        }
        .onAppear() {
            Task { expireCodesIfNewDay() }
        }
    }
    
    private func expireCodesIfNewDay() {
        let calendar = Calendar.current
        let now = Date()
        
        let last = Date(timeIntervalSince1970: lastLaunchDateSeconds)
        if lastLaunchDateSeconds == 0 || !calendar.isDate(last, inSameDayAs: now) {
            let sentExtensionCodeService = SentExtensionCodeService(storage: SentExtensionCodeStorageService(database: LocalDatabase.shared.databaseWriter))
            
            var codes = sentExtensionCodeService.getSentExtensionCodes()
            for i in codes.indices where codes[i].isCodeValid {
                codes[i].isCodeValid = false
                sentExtensionCodeService.upsertSentExtensionCode(SentExtensionCode: codes[i])
            }
        }
        
        lastLaunchDateSeconds = now.timeIntervalSince1970
    }
}
