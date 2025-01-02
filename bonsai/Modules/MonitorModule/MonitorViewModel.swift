//
//  MonitorViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Combine
import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

class MonitorViewModel: ObservableObject {
    @Published var pickerIsPresented: Bool = false
    @Published var monitoringStarted: Bool = false
    @Published var timeLimitMinutesString: String = "1"
    @Published var enteredPin: String = ""
    @Published var pinError: String? = nil
    @Published var activitySelection = FamilyActivitySelection()

    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" // Replace with your actual App Group ID
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // Testing
    let correctPin = "123456"

    public func startMonitoring() {
        let center = DeviceActivityCenter()

        let timeLimitMinutes = Int(timeLimitMinutesString) ?? 1

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        let event = DeviceActivityEvent(
            applications: activitySelection.applicationTokens,
            categories: activitySelection.categoryTokens,
            webDomains: activitySelection.webDomainTokens,
            threshold: DateComponents(minute: 0)
        )

        let activityName = DeviceActivityName("ScreenTimeActivity")
        let eventName = DeviceActivityEvent.Name("ScreenTimeThreshold")
        
        let encoded = try! JSONEncoder().encode(activitySelection)
        sharedDefaults?.set(encoded, forKey: userDefaultsKey)
        
        try! center.startMonitoring(
            activityName,
            during: schedule,
            events: [eventName: event]
        )
        
        monitoringStarted = true
    }

    public func clearAllRestrictions() {
        let store = ManagedSettingsStore()
        store.shield.applicationCategories = nil
        store.shield.applications = nil
        monitoringStarted = false
    }

    public func validateAndExtendTime() {
            if enteredPin == correctPin {
                pinError = nil

                // 1) Stop existing monitoring session
                let center = DeviceActivityCenter()
                do {
                    try center.stopMonitoring([DeviceActivityName("ScreenTimeActivity")])
                    print("Stopped existing monitoring session.")
                } catch {
                    print("Failed to stop monitoring: \(error)")
                }

                // 2) Increase daily limit, e.g. add 15 more minutes
                let currentLimit = Int(timeLimitMinutesString) ?? 1
                let newLimit = currentLimit + 15 // Increase by 15, or any value you want
                timeLimitMinutesString = String(newLimit)

                // 3) Restart monitoring with new limit
                startMonitoring()

            } else {
                pinError = "Invalid PIN. Please try again."
            }
        }
    
    public func saveSelection(for selection: FamilyActivitySelection) {
        activitySelection = selection
    }
}
