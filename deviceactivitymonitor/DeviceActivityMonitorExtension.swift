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
    private let appGroupID = "group.com.bonsai"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        if let data = sharedDefaults!.data(forKey: BOUNDARIES_STRING) {
            print("abt to decode")
            var boundaries = try! JSONDecoder().decode([Boundary].self, from: data)
            print("bounadry limi reacehd", activity.rawValue)

            if var boundary = boundaries.first(where: { $0.id == UUID(uuidString: activity.rawValue) }) {
                print(boundary)
                boundary.isBlocked = true
                
                boundary.appTokens.forEach { token in handleThresholdReached(appToken: token) }
                boundary.categoryTokens.forEach { token in handleThresholdReached(categoryToken: token) }
                boundary.webDomainTokens.forEach { token in handleThresholdReached(webDomainToken: token) }
                
                boundaries.removeAll(where: { $0.id == boundary.id })
                boundaries.append(boundary)
                
                sharedDefaults?.set(try! JSONEncoder().encode(boundaries), forKey: BOUNDARIES_STRING)
            }
        } else {
            print("bad key")
        }
    }
    
    private func handleThresholdReached(appToken: ApplicationToken) {
        if var applications = store.shield.applications {
            applications.insert(appToken)
            store.shield.applications = applications
        } else {
            store.shield.applications = [appToken]
        }
    }
    
    private func handleThresholdReached(categoryToken: ActivityCategoryToken) {
        print("\n\n\(categoryToken)")
        if let categories = store.shield.applicationCategories {
            switch categories {
            case .none:
                // If no categories are shielded, switch to specific with the new category.
                store.shield.applicationCategories = .specific([categoryToken], except: [])
                
            case .specific(var specificCategories, let exceptions):
                // If categories are specific, add the new category.
                specificCategories.insert(categoryToken)
                print(specificCategories, exceptions)
                store.shield.applicationCategories = .specific(specificCategories, except: exceptions)
                
            case .all(_): break
            @unknown default: break
            }
        } else {
            // If it's nil, initialize with specific categories
            store.shield.applicationCategories = .specific([categoryToken], except: [])
        }
    }
    
    private func handleThresholdReached(webDomainToken: WebDomainToken) {
        if var webDomains = store.shield.webDomains {
            webDomains.insert(webDomainToken)
            store.shield.webDomains = webDomains
        } else {
            store.shield.webDomains = [webDomainToken]
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
