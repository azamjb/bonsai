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

public enum GroupDisplayType: String {
    case limit = "LimitEvent+"
    case block = "BlockGroup+"
}

struct ScreenTimeActivityEvent: Codable {
    let id: UUID
    let appTokens: Set<ApplicationToken>?
    let categoryTokens: Set<ActivityCategoryToken>?
    let webDomainTokens: Set<WebDomainToken>?
    let hours: Int
    let minutes: Int
}

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let appGroupID = "group.com.bonsai"
    
    let store = ManagedSettingsStore()

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        let data = sharedDefaults!.data(forKey: GroupDisplayType.limit.rawValue + activity.rawValue)
        
        do {
            let activityEvent = try JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data!)
            
            if let appTokens = activityEvent.appTokens {
                appTokens.forEach { token in handleThresholdReached(appToken: token) }
            }
            if let categoryTokens = activityEvent.categoryTokens {
                categoryTokens.forEach { token in handleThresholdReached(categoryToken: token) }
            }
            if let webDomainTokens = activityEvent.webDomainTokens {
                webDomainTokens.forEach { token in handleThresholdReached(webDomainToken: token) }
            }
            
            sharedDefaults?.set(data, forKey: GroupDisplayType.block.rawValue + activityEvent.id.uuidString)
        } catch {
            print("Failed to decode limit event")
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
        if let categories = store.shield.applicationCategories {
            switch categories {
            case .none:
                // If no categories are shielded, switch to specific with the new category.
                store.shield.applicationCategories = .specific([categoryToken], except: [])
                
            case .specific(var specificCategories, let exceptions):
                // If categories are specific, add the new category.
                specificCategories.insert(categoryToken)
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
