//
//  DeviceActivityMonitorExtension.swift
//  deviceactivitymonitor
//
//  Created by Azam Jawad on 2024-11-28.
//

import DeviceActivity
import ManagedSettings
import ManagedSettingsUI
import SwiftUI

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let boundaryService = BoundaryService(storage: BoundaryStorageService(database: LocalDatabase.shared.databaseWriter))
    let sentExtensionCodeService = SentExtensionCodeService(storage: SentExtensionCodeStorageService(database: LocalDatabase.shared.databaseWriter))

    let store = ManagedSettingsStore()
    
    private func unshieldApps() {
        store.shield.applications = nil
        store.shield.webDomains = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
    }
    
    private func deactivateExtensionCodesForYesterday() {
        var extensionCodes: [SentExtensionCode] = sentExtensionCodeService.getSentExtensionCodes()
        
        let yesterday = Date.yesterday
        
        extensionCodes = extensionCodes.filter({ areDatesSameDay(date1: yesterday, date2: $0.sentDateTimeUtc) }).map { code in
            var updatedCode = code
            updatedCode.isCodeValid = false
            return updatedCode
        }
        
        extensionCodes.forEach(sentExtensionCodeService.upsertSentExtensionCode)
    }
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue.hasSuffix(EXTENSION_SUFFIX_STRING) { return }

        unshieldApps()
        deactivateExtensionCodesForYesterday()
        boundaryService.unblockAllBoundaries()

        stopAllExtensionMonitoring()
    }
    private func stopAllExtensionMonitoring() {
        let center = DeviceActivityCenter()
        let toStop = center.activities.filter { $0.rawValue.hasSuffix(EXTENSION_SUFFIX_STRING) }
        if !toStop.isEmpty {
            center.stopMonitoring(toStop)
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        if event.rawValue != BOUNDARY_STRING { return }
        
        // remove the extension suffix to get the pure boundary id
        let raw = activity.rawValue
        let isExtensionActivity = raw.hasSuffix(EXTENSION_SUFFIX_STRING)
        let idString = isExtensionActivity ? String(raw.dropLast(EXTENSION_SUFFIX_STRING.count)) : raw

        guard let boundaryId = UUID(uuidString: idString) else { return }
        
        let boundaries = boundaryService.getBoundaries()
        
        if var boundary = boundaries.first(where: { $0.id == boundaryId }) {
            guard boundary.weekdays.contains(Weekday.today) else {
                print("Boundary '\(boundary.givenName)' not active on \(Weekday.today)")
                return
            }
            
            boundary.appTokens.forEach { token in handleThresholdReached(appToken: token) }
            boundary.categoryTokens.forEach { token in handleThresholdReached(categoryToken: token) }
            boundary.webDomainTokens.forEach { token in handleThresholdReached(webDomainToken: token) }
            
            boundary.isBlocked = true
            boundaryService.upsertBoundary(boundary: boundary)
        }
        
        // since extensions are a one time thing, end the activity
        if activity.rawValue.hasSuffix(EXTENSION_SUFFIX_STRING) {
            let center = DeviceActivityCenter()
            center.stopMonitoring([activity])
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
