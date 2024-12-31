//
//  DeviceActivityMonitorExtension.swift
//  deviceactivitymonitor
//
//  Created by Azam Jawad on 2024-11-28.
//

import DeviceActivity
import ManagedSettings
import ManagedSettingsUI
import SwiftUICore
import FamilyControls


// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" // Replace with your actual App Group ID
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Handle the start of the interval.
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
    }
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
            super.eventDidReachThreshold(event, activity: activity)
        
            print("Screen time exceeded for monitored activity: \(activity.rawValue)")
            writeHello()
            let store = ManagedSettingsStore()

            // Retrieve the saved selection from shared UserDefaults
            guard let data = sharedDefaults?.data(forKey: userDefaultsKey) else {
                print("No data found in shared UserDefaults for key: \(userDefaultsKey)")
                return
            }

            do {
                let selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)

                // Apply restrictions using the selected category tokens
                if !selection.categoryTokens.isEmpty {
                    store.shield.applicationCategories = .some(.specific(selection.categoryTokens))
                    print("Restrictions applied to selected categories: \(selection.categoryTokens)")

                    
                } else {
                    print("No category tokens available in the selection.")
                }
            } catch {
                print("Failed to decode selection: \(error)")
            }
        }


    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
