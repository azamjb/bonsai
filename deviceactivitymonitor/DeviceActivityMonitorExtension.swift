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
import _DeviceActivity_SwiftUI

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
        
        let decoder = JSONDecoder()
        if let data = sharedDefaults?.data(forKey: userDefaultsKey) {
            let activitySelection = try! decoder.decode(FamilyActivitySelection.self, from: data)
            
            handleThresholdReached(activitySelection: activitySelection)
        }
    }
    
    private func handleThresholdReached(activitySelection: FamilyActivitySelection) {
        let settingsStore = ManagedSettingsStore()
        
        settingsStore.shield.applications = activitySelection.applicationTokens
        settingsStore.shield.applicationCategories = .specific(activitySelection.categoryTokens)
        settingsStore.shield.webDomains = activitySelection.webDomainTokens
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
